function [] = generic_callback(ob);
   
     obj = get(gcbo, 'UserData'); 
     obj = SoloParamHandle(obj); 
     callback(obj);
     
     
