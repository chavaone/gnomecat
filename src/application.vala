/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of valacat
 *
 * Copyright (C) 2013 - Marcos Chavarría Teijeiro
 *
 * valacat is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * valacat is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with valacat. If not, see <http://www.gnu.org/licenses/>.
 */

using Gtk;
using ValaCAT.UI;
using ValaCAT.FileProject;

namespace ValaCAT.Application
{
    public class Application : Gtk.Application
    {

        private Application ()
        {
            Object (application_id: "info.aquelando.valacat",
                flags: ApplicationFlags.HANDLES_OPEN);
        }

        public override void activate ()
        {
            ValaCAT.UI.Window window = new ValaCAT.UI.Window (this);
            window.show_all ();
            Gtk.main ();
        }

        public override void open (GLib.File[] files, string hint)
        {
            ValaCAT.UI.Window window = new ValaCAT.UI.Window (this);

            foreach (GLib.File f in files)
            {
                window.add_tab (new FileTab(new ValaCAT.Demo.DemoFile ()));
            }

            ValaCAT.FileProject.Project p = new Project ("");

            p.add_file (new ValaCAT.Demo.DemoFile ());
            p.add_file (new ValaCAT.Demo.DemoFile ());

            window.add_tab (new ProjectTab(p));

            window.show_all ();
            Gtk.main ();
        }

        public static int main (string[] args)
        {
            /*Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
            Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
            Intl.textdomain (Config.GETTEXT_PACKAGE);
            */

            var app = new Application ();
            return app.run (args);
        }

    }
}