/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of GNOMECAT
 *
 * Copyright (C) 2014 - Marcos Chavarría Teijeiro
 *
 * GNOMECAT is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * GNOMECAT is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with GNOMECAT. If not, see <http://www.gnu.org/licenses/>.
 */

namespace GNOMECAT
{

    public class PluginManager
    {
        private GNOMECAT.Application app;
        Peas.Engine engine;
        Peas.ExtensionSet exts;

        public PluginManager (GNOMECAT.Application app)
        {
            this.app = app;

            engine = Peas.Engine.get_default ();
            engine.enable_loader ("python");
            engine.enable_loader ("gjs");
            string plugins_path = Path.build_filename (Config.LIBDIR, "plugins");
            engine.add_search_path (plugins_path, null);

            // Load all the plugins found
            foreach (var plug in engine.get_plugin_list ()) {
                if (engine.try_load_plugin (plug)) {
                    debug ("Plugin Loaded:" + plug.get_name ());
                } else {
                    warning ("Could not load plugin:" + plug.get_name ());
                }
            }

            /* Our extension set */
            Parameter param = Parameter();
            param.value = app;
            param.name = "object";

            exts = new Peas.ExtensionSet (engine, typeof(Peas.Activatable), "object", app, null);
            exts.extension_removed.connect(on_extension_removed);
            exts.foreach (extension_foreach);

        }

        void extension_foreach (Peas.ExtensionSet set, Peas.PluginInfo info, Peas.Extension extension) {
            debug ("Extension added");
            ((Peas.Activatable) extension).activate ();
        }

        void on_extension_removed (Peas.PluginInfo info, Object extension) {
            ((Peas.Activatable) extension).deactivate ();
        }
    }

}