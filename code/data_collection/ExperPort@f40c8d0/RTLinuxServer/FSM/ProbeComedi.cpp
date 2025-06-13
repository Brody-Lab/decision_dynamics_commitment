#include <iostream>
#include <sstream>
#include <map>
#include <string>

#include <comedilib.h>
#include <errno.h>
#include <string.h>

struct ChanTypeAndCount
{
  ChanTypeAndCount() {}
  ChanTypeAndCount(const std::string & s, unsigned c) : chanType(s), count(c){}
  std::string chanType;
  unsigned count;
};

typedef std::map<unsigned, ChanTypeAndCount> SDevChanMap;

std::string subdevTypeToString(unsigned subdev_type)
{
  switch (subdev_type) {
  case COMEDI_SUBD_AI: return "AI";
  case COMEDI_SUBD_AO: return "AO";
  case COMEDI_SUBD_DI: return "DI";
  case COMEDI_SUBD_DO: return "DO";
  case COMEDI_SUBD_DIO: return "DIO";
  case COMEDI_SUBD_COUNTER: return "CT";
  }    
  return "??";
}


static int get_num_chans(comedi_t *it, unsigned subdev_type, SDevChanMap * sdevs = 0)
{
  unsigned num_chans = 0;
  int sdev = -1;
  while ( (sdev = ::comedi_find_subdevice_by_type(it, subdev_type, sdev+1)) >= 0) {
    int ret = ::comedi_get_n_channels(it, sdev);
    if (ret > 0) {
      num_chans += ret;
      if (sdevs) {
        
        (*sdevs)[sdev] = ChanTypeAndCount(subdevTypeToString(subdev_type), ret);
      }
    }
  }
  return num_chans;
}

int main(void)
{
  
  int start = 0, end = 15, have_devs = 0;
  std::cout << "Probing all comedi devices from /dev/comedi" << start << " -> /dev/comedi" << end << std::endl;
  for (int minor = start; minor <= end; ++minor) 
  {
    std::stringstream ss;
    ss << "/dev/comedi" << minor;
    const std::string devfile( ss.str() );
    comedi_t *dev = ::comedi_open(devfile.c_str());
    if (!dev) {
      if (!have_devs || ::comedi_errno() != ENODEV)
        // only display error message when we haven't a comedi device yet
        // or if it's something other than ENODEV
        std::cerr << devfile << ": " 
                << ::comedi_strerror(::comedi_errno()) << std::endl;
      continue;
    }
    ++have_devs;
    SDevChanMap sds[6];
    int ver = ::comedi_get_version_code(dev);
    int nai = get_num_chans(dev, COMEDI_SUBD_AI, &sds[0]), 
        nao = get_num_chans(dev, COMEDI_SUBD_AO, &sds[1]), 
        nct = get_num_chans(dev, COMEDI_SUBD_COUNTER, &sds[2]), 
        ndio = get_num_chans(dev, COMEDI_SUBD_DIO, &sds[3]), 
        ndi = get_num_chans(dev, COMEDI_SUBD_DI, &sds[4]), 
        ndo = get_num_chans(dev, COMEDI_SUBD_DO, &sds[5]);
    
    
    std::cout << devfile << ": " << std::endl;
    std::cout << "\tBoard: " << ::comedi_get_board_name(dev) 
              << "\n\tDriver: " << ::comedi_get_driver_name(dev) 
              << "\n\tVersion: " << (0xff&(ver>>16)) << "." << (0xff&(ver>>8)) << "." << (0xff&(ver>>0))
              << "\n\tChannels:" 
              << "  " << nai << " AI" 
              << ", " << nao << " AO"
              << ", " << nct << " COUNTER"
              << ", " << ndio << " DIO" 
              << ", " << ndi << " DI" 
              << ", " << ndo << " DO" 
      
              << "\n"

              << std::endl;        

    std::cout << "\tChannel Breakdown:\n";
    for (int i = 0; i < 6; ++i) 
    {
        SDevChanMap::iterator it;
        for (it = sds[i].begin(); it != sds[i].end(); ++it) 
        {
            std::cout << "\t\t Subdev ID:" << it->first 
                      << " of type " << it->second.chanType 
                      << " has " << it->second.count << " channels.\n";
        }
    }

    comedi_close(dev);
  }
  return 0;
}
