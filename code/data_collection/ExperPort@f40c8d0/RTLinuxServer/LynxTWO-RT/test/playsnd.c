
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/errno.h>

#include "LynxTWO-RT.h"
#include "sound.h"

#define MODULE_NAME "TestSound"
#ifdef MODULE_LICENSE
MODULE_LICENSE("GPL");
#endif



int init(void)
{
	int ret;
	
	if (!L22Exists()) {
		printk(KERN_ERR MODULE_NAME": L22Exists() returned false!\n");
		return -EINVAL;
	}
	
	ret = L22SetAudioBuffer((void *)sound_raw, sizeof(sound_raw), 192000, PCM32|MONO);

	if (!ret) {
		printk(KERN_INFO MODULE_NAME": L22SetAudioBuffer() returned %d\n", ret);
		return -EINVAL;
	}

	ret = L22Play();
	
	if (!ret) {
		printk(KERN_INFO MODULE_NAME": L22Play() returned %d\n", ret);
		L22SetAudioBuffer(0, 0, 0, 0);
		return -EINVAL;
	}

	return 0;
}

void cleanup(void)
{
	L22Stop();
}

module_init(init);
module_exit(cleanup);
