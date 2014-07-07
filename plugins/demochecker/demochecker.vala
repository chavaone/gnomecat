

namespace DemoPlugins
{

    public class DemoChecker : Peas.ExtensionBase,  Peas.Activatable
    {
        public Object object  { owned get; construct; }

        public void activate ()
        {
            print ("DEMO CHECKER:: ACTIVANDO \\o/");
        }

        public void deactivate ()
        {

        }

        public void update_state ()
        {

        }
    }


    [ModuleInit]
    public void peas_register_types (GLib.TypeModule module)
    {
        var objmodule = module as Peas.ObjectModule;
        objmodule.register_extension_type (typeof (Peas.Activatable),
                                           typeof (DemoChecker));
    }
}