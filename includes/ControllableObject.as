// ActionScript file
import com.yogurt3d.core.objects.IController;
import flash.utils.Dictionary;
import com.yogurt3d.core.managers.DependencyManager;
import org.swiftsuspenders.Injector;

import com.yogurt3d.YOGURT3D_INTERNAL;

YOGURT3D_INTERNAL var m_injector:Injector;

private var m_controllerDict:Dictionary;

public function get injector():Injector{
	return YOGURT3D_INTERNAL::m_injector;
}

public function addController(name:String, controllerClass:Class, ... p):IController{
	var ins:IController;
	switch (p.length)
	{
		case 0 : ins = new controllerClass(); break;
		case 1 : ins = new controllerClass(p[0]); break;
		case 2 : ins = new controllerClass(p[0], p[1]); break;
		case 3 : ins = new controllerClass(p[0], p[1], p[2]); break;
		case 4 : ins = new controllerClass(p[0], p[1], p[2], p[3]); break;
		case 5 : ins = new controllerClass(p[0], p[1], p[2], p[3], p[4]); break;
		case 6 : ins = new controllerClass(p[0], p[1], p[2], p[3], p[4], p[5]); break;
		case 7 : ins = new controllerClass(p[0], p[1], p[2], p[3], p[4], p[5], p[6]); break;
		case 8 : ins = new controllerClass(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]); break;
		case 9 : ins = new controllerClass(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8]); break;
		case 10 :ins = new controllerClass(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9]); break;
	}
	p.length = 0;
	
	if( ins is IController ){
		DependencyManager.registerObject( this, ins);
	}else{
		throw new Error("Controller classes must implement IController");
	}
	m_controllerDict[name] = ins;
	return ins;
}

public function getController(name:String):IController{
	return m_controllerDict[name];
}
public function hasController(name:String):Boolean{
	return m_controllerDict[name] != null;
}

public function removeController(name:String):IController{
	var comp:IController = m_controllerDict[name];
	if( comp )
	{
		delete m_controllerDict[name];
		comp.dispose();
	}
	return comp;
}
public function removeAllController():void{
    for( var name:String in m_controllerDict )
    {
        removeController(name);
    }
}
public function getAllControllers():Array{
    var arr:Array = [];
    for( var name:String in m_controllerDict )
    {
        arr.push(getController(name));
    }
    return arr;
}