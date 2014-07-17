

namespace DemoPlugins
{

    public class DemoChecker : Peas.ExtensionBase,  Peas.Activatable
    {
        public Object object  { owned get; construct; }

        public void activate ()
        {
            (object as GNOMECAT.API).check_message.connect (on_check_message);
        }

        public void deactivate ()
        {
            (object as GNOMECAT.API).check_message.disconnect (on_check_message);
        }

        public void update_state ()
        {
        }

        private void on_check_message (GNOMECAT.Message m)
        {
                int random;
                if (m.state != GNOMECAT.MessageState.UNTRANSLATED)
                {
                    random = Random.int_range (0,9);
                    for (int i = 0; i < random; i++)
                    {
                        int n = Random.int_range (0,3);
                        m.add_tip (
                            new GNOMECAT.MessageTip (
                                "Just a tip",
                                "fkldsajlfkjdalkdfjalksdjflñ",
                                n == 0 ? GNOMECAT.TipLevel.INFO :
                                n == 1 ? GNOMECAT.TipLevel.WARNING :
                                GNOMECAT.TipLevel.ERROR,
                                null,
                                null));
                    }
                }
        }
    }
}

[ModuleInit]
public void peas_register_types (GLib.TypeModule module)
{
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type (typeof (Peas.Activatable),
                                       typeof (DemoPlugins.DemoChecker));
}