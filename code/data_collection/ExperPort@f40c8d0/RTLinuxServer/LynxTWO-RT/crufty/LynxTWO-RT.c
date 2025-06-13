#define EXPORT_SYMTAB 1
#include <linux/module.h>
#include <linux/pci.h>
#include <linux/pci_ids.h>
#include <linux/ioport.h>
#include <linux/sched.h>
#include <asm/io.h>
#include <asm/page.h>

#include "L22.h" /* Registers, offsets, etc.. */

/*---------------------------------------------------------------------------
  DECLARATIONS AND CONSTANTS
-----------------------------------------------------------------------------*/

#define MODULE_NAME "LynxTWO-RT"
#define DRIVER MODULE_NAME

#define LOG_MSG(x...) printk("<1>"MODULE_NAME": "x)

#define PCI_VENDOR_ID_LYNX_STUDIO_TECHNOLOGY 0x1621
#define PCI_DEVICE_ID_LYNX_L22 PCIDEVICE_LYNX_L22 /* From L22.h */

#define VENDOR_ID PCI_VENDOR_ID_LYNX_STUDIO_TECHNOLOGY
#define DEVICE_ID PCI_DEVICE_ID_LYNX_L22

static struct pci_device_id pci_table[] __devinitdata = {
  { VENDOR_ID, DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
  { 0 }
};

/*
static struct pci_driver driver = { 
  .name = DRIVER,
  .id_table = &pci_table,
  .probe = NULL,
  .remove = NULL,
  .save_state = NULL,
  .suspend = NULL,
  .resume = NULL,
  .enable_wake = NULL 
};
*/

MODULE_DEVICE_TABLE(pci, pci_table);

struct lynx_private {
        char name[90];
        unsigned long bar[2]; /* Memory-mapped IO addresses, set by probe */
        struct pci_dev *pci_dev;
  /* IRQ Handler, for now this only acts as a boolean, so that we know
     that if this is non-NULL, we should tell linux to clear the irq.. */
        void (*handler)(int, void *, struct pt_regs *);

        struct L22DMABufferList *dmaVirt; /* Pointer to 2048-byte DMA buffer list + 1MB DMA buffer area */
        dma_addr_t dmaPhys; /* Physical address of above */
        void *dmaBuffers[NUM_BUFFERS_PER_STREAM]; /* Just pointers into the dma buffer area */
        unsigned long dmaBuffersPhys[NUM_BUFFERS_PER_STREAM]; /* Just pointers into the dma buffer area, but physically (used to reset dma registers)  */

  
        struct {
          unsigned *buf; /* Pointer to samples, provided by client code.  
                            Each sample is u32... */
          unsigned ct;   /* How many samples total..  */
          unsigned played_ct; /* The number of samples played. */
          unsigned rate; /* The sampling rate.. */
          int loop;      /* If true, loop play. */
          int playing;   /* If true, we are currently playing, if false, stop. */          
        } play;
  
};

/* TODO: make this not global to this module, but allocated at run-time
   and saved in struct pci_dev's driver_data pointer.. */
static struct lynx_private prv = { 
  .name = "LynxTWO-RT-Calin",
  .bar = {0, 0},
  .pci_dev = NULL,
  .handler = NULL,
  .dmaVirt = NULL,
  .dmaPhys = 0,
  .dmaBuffers = { 0 /*.. */},
  .dmaBuffersPhys = { 0 /*.. */},
  .play = { .buf = NULL, .ct = 0, .loop = 0, .playing = 0 }
};

MODULE_AUTHOR("Calin A. Culianu <calin@rtlab.org>");             
MODULE_LICENSE("GPL");

#define DMA_BUF_SIZE (64*1024) /* Try to make each DMA buffer be 16KB */
#define DMA_AREA_SIZE (sizeof(struct L22DMABufferList) + DMA_BUF_SIZE * NUM_BUFFERS_PER_STREAM)

/*---------------------------------------------------------------------------
  DEVICE-SPECIFIC CONSTANTS
-----------------------------------------------------------------------------*/

/* See L22.h ... */

/*---------------------------------------------------------------------------
  FUNCTION DECLARATIONS
-----------------------------------------------------------------------------*/

int init(void);
void cleanup(void);

module_init(init);
module_exit(cleanup);


/* 
 *  Probes for a supported device.
 */
static int probe(void);

static void interrupt_handler (int irq, void *dev_instance, struct pt_regs *regs);
static inline unsigned long readRegion32(unsigned badr_num, unsigned offset);
static inline void writeRegion32(unsigned badr_num, unsigned offset, 
                              unsigned long word);
static int lynxDMAEnable(struct lynx_private *p);
static void lynxDMADisable(struct lynx_private *p);
static int loadNextDMA(unsigned short dma_buffers_mask, int start_buf_num);
static void setDMABufSize(int bufnum, unsigned sz);

/* Exported functions to client code.. */
/* Return true on success, false on failure.. */

int lynxSetSamples(unsigned *sampleBuf,  /* Pointer to persistent buffer */
                   unsigned n_samples, unsigned rate, int loop);
int lynxPlayStop(void); /* Plays the sample set above, or stops if is playing  */ 
                   
EXPORT_SYMBOL_NOVERS(lynxSetSamples);
EXPORT_SYMBOL_NOVERS(lynxPlayStop);

/*---------------------------------------------------------------------------
  FUNCTION DEFINITIONS
-----------------------------------------------------------------------------*/


/* 
 *  Probes for a supported device.
 *
 */
static int probe(void) 
{
    int found = 0;
    struct pci_dev *pdev;

    if (!pci_present()) return -ENODEV;

    pdev = pci_find_device(VENDOR_ID, DEVICE_ID, NULL);
    
    if (pdev) {
      int i;

      LOG_MSG("Found our device %04x:%04x \"%s\" -- \n", 
              (unsigned) pdev->vendor,  (unsigned) pdev->device, 
              pdev->name);
      LOG_MSG("resources: ");

      /* PCI devices need to be enabled before they can be used.. */
      pci_enable_device(prv.pci_dev = pdev);
      pci_set_master(pdev);

      for (i = 0; i < 2; ++i) {
        void *ioaddr;
        unsigned long mmio_start, mmio_end, mmio_len, mmio_flags;

        mmio_start = pci_resource_start(pdev, i);
        mmio_end = pci_resource_end(pdev, i);
        mmio_len = pci_resource_len(pdev, i);
        mmio_flags = pci_resource_flags(pdev, i);
        
        
        printk("r%d -> %x %s", i, (unsigned)mmio_start, 
               mmio_flags & IORESOURCE_MEM ? "(Memory mapped)" : "(Port IO)");
        
        /* make sure above region is MMIO */
        if(!(mmio_flags & IORESOURCE_MEM)) {
          LOG_MSG("Memory mapped IO not flagged for BAR%d, aborting driver initialization...\n", i);
          found--;
          break;
        }
	
        /* get PCI memory space */
        if(pci_request_region(pdev, i, DRIVER)) {
          LOG_MSG("Could not get PCI region BAR%d\n", i);
          found--;
          break;
        }

        /* ioremap MMIO region */
        ioaddr = ioremap(mmio_start, mmio_len);
        if(!ioaddr) {
          LOG_MSG("Could not ioremap region BAR%d\n", i);
          found--;
          break;
        }

        prv.bar[i] = (unsigned long)ioaddr;
        
        printk("  ");

      }
      printk("\n");

      if (!lynxDMAEnable(&prv)) {
        LOG_MSG("DMA Enable failure, aborting!");
        found--;
      }

      found++;
    }

    if (!found) {
        LOG_MSG("Our device %04x:%04x was not found!\n", 
                (unsigned)VENDOR_ID, (unsigned)DEVICE_ID);
        return -ENODEV;
    }

    /* TODO: RT-ify this IRQ! */
    if ( request_irq(prv.pci_dev->irq, interrupt_handler, SA_SHIRQ, prv.name, 
                     prv.pci_dev) )  {
      LOG_MSG("Could not get irq %d from Linux\n", prv.pci_dev->irq);
      return -EINVAL;
    }

    prv.handler = interrupt_handler;

    return 0;
}

int init(void)
{  
  int ret = probe();
  
  if (ret) cleanup();

  return ret;
}

void cleanup(void)
{
  if (prv.pci_dev) {    
    int i;

    lynxDMADisable(&prv);    

    pci_disable_device(prv.pci_dev);

    if (prv.handler) {
      free_irq(prv.pci_dev->irq, prv.pci_dev);
      prv.handler = 0;
    }

    for (i = 0; i < 2; ++i) {
      pci_release_region(prv.pci_dev, i);
      if (prv.bar[i]) iounmap((void *)prv.bar[i]);
      prv.bar[i] = 0;
    }
    prv.pci_dev = 0;
  }
}

static int lynxDMAEnable(struct lynx_private *p)
{
  int i;
  unsigned long addr;
  char *vAddr;

  p->dmaVirt = (struct L22DMABufferList *) pci_alloc_consistent(p->pci_dev, DMA_AREA_SIZE, &p->dmaPhys);

  if (!p->dmaVirt) {
    LOG_MSG("Could not allocate %d bytes for DMA Buffer Area, aborting!",
            DMA_AREA_SIZE);
    return 0;
  }
  
  memset(p->dmaVirt, 0, DMA_AREA_SIZE);

  /* Start our DMA address pointer out after the buffer list struct..
     then dole out the pool to each stream */
  addr = p->dmaPhys + sizeof(struct L22DMABufferList);
  vAddr = ((char *)p->dmaVirt) + sizeof(struct L22DMABufferList);
  
  for (i = 0; i < NUM_BUFFERS_PER_STREAM; ++i) {
    int j;
    for (j = 0; j < NUM_WAVE_DEVICES;  ++j) {
      /* NB: in our naive implementation, 
         all wave devices use the same exact DMA buffer memory, so 
         that means that effectively we can only play or record one channel
         at a time.. */
      p->dmaVirt->record[j].entry[i].hostPtr = addr;
      p->dmaVirt->record[j].entry[i].control = DMA_BUF_SIZE;
    }
    p->dmaBuffers[i] = vAddr;
    p->dmaBuffersPhys[i] = addr;
    addr += DMA_BUF_SIZE;
    vAddr += DMA_BUF_SIZE;
  }
      
  /* inform the hardware where the DMA Double Buffer is Located
     only shift out 10 bits because GDBLADDR starts at bit position 1 */
  writeRegion32( 0, L22_DMACTL, ((p->dmaPhys >> 10) | L22_REG_DMACTL_GDMAEN) );
  
  return 1;
}

static void lynxDMADisable(struct lynx_private *p)
{

  writeRegion32(0, L22_DMACTL, 0x0UL);

  if (prv.dmaVirt) 
    pci_free_consistent(p->pci_dev, DMA_AREA_SIZE, p->dmaVirt, p->dmaPhys);

  p->dmaVirt = NULL;
  p->dmaPhys = 0;
  memset(p->dmaBuffers, 0, sizeof(p->dmaBuffers));
}

static inline void writeRegion32(unsigned bar_num, unsigned offset, unsigned long word)
{
  if (bar_num < 2 && prv.bar[bar_num]) 
    writel(word, prv.bar[bar_num] + offset);
}

static inline unsigned long readRegion32(unsigned bar_num, unsigned offset)
{
  if (bar_num >= 2 || !prv.bar[bar_num]) return 0;
  return readl(prv.bar[bar_num] + offset);
}

static void interrupt_handler (int irq, 
                               void *dev_instance, 
                               struct pt_regs *regs)
{
  static int count = 0;

  if ( !readRegion32(0, L22_AISTAT) ) {
    LOG_MSG("Spurious interrupt for Lynx22 board?");
    return;
  }

  LOG_MSG("Got IRQ %d, count=%d!\n", irq, ++count);
  (void)dev_instance;
  (void)regs;
}

static int loadNextDMA(unsigned short mask, int first)
{
  int i;

  if ( !prv.play.buf || (!prv.play.loop && prv.play.played_ct >= prv.play.ct) ) return 0;  

  if (prv.play.loop && prv.play.played_ct >= prv.play.ct) 
    prv.play.played_ct = 0;
  
  for (i = first; (i-first) < NUM_BUFFERS_PER_STREAM && prv.play.played_ct < prv.play.ct ; ++i) {
    int bufnum = i % NUM_BUFFERS_PER_STREAM;
    if (mask && (0x1<<bufnum)) {
      unsigned num = prv.play.ct - prv.play.played_ct;
      if (num*sizeof(unsigned) > DMA_BUF_SIZE) 
        num = DMA_BUF_SIZE/sizeof(unsigned);
      memcpy(prv.dmaBuffers[bufnum], &prv.play.buf[prv.play.played_ct], num*sizeof(unsigned));
      setDMABufSize(bufnum, num*sizeof(unsigned));
      prv.play.played_ct += num;
    } else
      setDMABufSize(bufnum, 0);
  }

  return 1;
}

int lynxSetSamples(unsigned *sampleBuf,  /* Pointer to persistent buffer */
                   unsigned n_samples, unsigned rate, int loop)
{
  if (rate < L22_MIN_SAMPLE_RATE || rate > L22_MAX_SAMPLE_RATE) return 0;

  if (prv.play.playing) lynxPlayStop(); /* stop playing.. */

  prv.play.buf = sampleBuf;
  prv.play.ct = n_samples;
  prv.play.loop = loop;
  prv.play.rate = rate;
  prv.play.played_ct = 0;
  prv.play.playing = 0;

  return loadNextDMA(~0, 0);
}

int lynxPlayStop(void) /* Plays the sample set above, or stops if is playing  */
{
  if (prv.play.playing) {
    /* stop */
    
  } else {
    /* play */

  }
  return 0;
}

static void setDMABufSize(int bufnum, unsigned sz)
{
  int i;
  for (i = 0; i < NUM_WAVE_DEVICES; ++i) {
    prv.dmaVirt->record[i].entry[bufnum].control = sz ? sz|DMACONTROL_HBUFIE : 0;
    prv.dmaVirt->record[i].entry[bufnum].hostPtr = prv.dmaBuffersPhys[bufnum];
  }
}
