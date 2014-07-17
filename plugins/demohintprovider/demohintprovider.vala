

namespace DemoPlugins
{

    public class DemoHintProvider : Peas.ExtensionBase,  Peas.Activatable
    {
        public Object object  { owned get; construct; }


        public void activate ()
        {
            (object as GNOMECAT.API).provide_hints.connect (on_provide_hints);
        }

        public void deactivate ()
        {
            (object as GNOMECAT.API).provide_hints.disconnect (on_provide_hints);
        }

        public void update_state ()
        {
        }

        private void on_provide_hints (GNOMECAT.Message m, GNOMECAT.HintViewer hv)
        {
            GNOMECAT.Hint h = new GNOMECAT.Hint (m.get_original_singular (), "DEMO", 0.3);
            hv.display_hint (m, h);
        }
    }
}

[ModuleInit]
public void peas_register_types (GLib.TypeModule module)
{
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type (typeof (Peas.Activatable),
                                       typeof (DemoPlugins.DemoHintProvider));
}