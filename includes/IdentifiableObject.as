import com.yogurt3d.core.managers.IDManager;

 /**
 * @inheritDoc
 * */
public function get systemID():String
{
	return IDManager.getSystemIDByObject(this);
}

/**
 * @inheritDoc
 * */
public function get userID():String
{
	return IDManager.getUserIDByObject(this);
}

/**
 * @inheritDoc
 * */
public function set userID(_value:String):void
{
	IDManager.setUserIDByObject(_value, this);
}