

namespace GNOMECAT
{

	public delegate void Callback ();

    public interface ChangedMessageSensible : Object
    {
        public abstract GNOMECAT.Message message {get;set;}
    }


    struct Accel
    {
        string name;
        string accel;
    }
}