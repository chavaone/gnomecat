

namespace DemoPlugins
{
    public class DemoHintProvider : GNOMECAT.HintProvider
    {
        protected override void on_provide_hints (GNOMECAT.Message m, GNOMECAT.HintViewer hv)
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