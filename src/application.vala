/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of valacat
 *
 * Copyright (C) 2013 - Marcos Chavarría Teijeiro
 *
 * valacat is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
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
using Gee;

namespace ValaCAT
{
    public class Application : Gtk.Application
    {
        private ArrayList<FileOpener> file_openers;
        private ArrayList<HintProvider> hint_providers;
        private ArrayList<Checker> checkers;
        private static ValaCAT.Application _instance;

        private ArrayList<string> _extensions;
        public ArrayList<string> extensions
        {
            get
            {
                _extensions = new ArrayList<string> ();
                foreach (FileOpener fo in file_openers)
                {
                    foreach (string ext in fo.extensions)
                        _extensions.add (ext);
                }
                return _extensions;
            }
        }

        private ValaCAT.Profiles.Profile? _enabled_profile;
        public ValaCAT.Profiles.Profile? enabled_profile
        {
            get
            {
                GLib.Settings prof_set = new GLib.Settings ("info.aquelando.valacat.ProfilesList");
                if (_enabled_profile == null)
                {
                    string prof_uuid = prof_set.get_string ("default");
                    _enabled_profile = prof_uuid == "" ? null : new ValaCAT.Profiles.Profile.from_uuid (prof_uuid);
                }
                return _enabled_profile;
            }
            set
            {
                GLib.Settings prof_set = new GLib.Settings ("info.aquelando.valacat.ProfilesList");
                _enabled_profile = value;
                prof_set.set_string ("default", value == null ? "" : value.uuid);
            }
        }

        private Application ()
        {
            Object (application_id: "info.aquelando.valacat",
                flags: ApplicationFlags.HANDLES_OPEN);
        }

        construct
        {
            file_openers = new ArrayList<FileOpener> ();
            add_opener (new ValaCAT.PoFiles.PoFileOpener ());
            this.window_removed.connect (on_window_removed);

            hint_providers = new ArrayList<HintProvider> ();
            add_hint_provider (new ValaCAT.Demo.DemoHintProvider ()); //DEMO

            checkers = new ArrayList<Checker> ();
            add_checker (new ValaCAT.Demo.DemoChecker ()); //DEMO
        }

        public static new ValaCAT.Application get_default ()
        {
            if (_instance == null)
                _instance = new Application ();
            return _instance;
        }

        public void add_opener (FileOpener o)
        {
            file_openers.add (o);
        }

        public void remove_opener (FileOpener o)
        {
            file_openers.remove (o);
        }

        public ValaCAT.FileProject.File? open_file (string path)
        {
            int index_last_point = path.last_index_of_char ('.');
            string extension = path.substring (index_last_point + 1);
            foreach (FileOpener o in file_openers)
            {
                if (extension in o.extensions)
                    return o.open_file (path, null);
            }
            return null;
        }

        public void add_hint_provider (HintProvider hp)
        {
            hint_providers.add (hp);
        }

        public void remove_hint_provider (HintProvider hp)
        {
            hint_providers.remove (hp);
        }

        public void get_hints (ValaCAT.FileProject.Message m,
            ValaCAT.UI.HintPanelWidget pannel)
        {
            foreach (HintProvider hp in hint_providers)
            {
                hp.get_hints (m, pannel);
            }
        }

        public void add_checker (Checker c)
        {
            checkers.add (c);
        }

        public void remove_checker (Checker c)
        {
            checkers.remove (c);
        }

        public void check_message (Message m)
        {
            foreach (Checker c in checkers)
            {
                c.check (m);
            }
        }

        public void select (ValaCAT.SelectLevel level,
            ValaCAT.FileProject.MessageFragment? fragment)
        {
            bool success = false;
            foreach (var w in get_windows ())
            {
                success |= (w as ValaCAT.UI.Window).select(level, fragment);
            }

            if (!success && fragment.file != null)
            {
                ValaCAT.FileProject.File file = open_file (fragment.file.file_path);
                if (file != null)
                    (get_active_window () as ValaCAT.UI.Window).add_file (file);
                else
                    stderr.printf ("Error while open %s file.\n", fragment.file.file_path);
            }
        }

        private void on_window_removed ()
        {
            foreach (var w in get_windows ())
                return;
            Gtk.main_quit ();
        }

        public override void activate ()
        {
            ValaCAT.UI.Window window = new ValaCAT.UI.Window (this);
            window.show ();
            Gtk.main ();
        }

        public override void open (GLib.File[] files, string hint)
        {
            ValaCAT.UI.Window window = new ValaCAT.UI.Window (this);

            foreach (GLib.File f in files)
            {
                ValaCAT.FileProject.File file = open_file (f.get_path ());
                if (file != null)
                    window.add_file (file);
                else
                    stderr.printf ("Error while open %s file.\n", f.get_path ());
            }

            //DEMO
            ValaCAT.FileProject.Project p = new Project ("/home/ch01/valacat");
            ValaCAT.FileProject.File f = new ValaCAT.Demo.DemoFile ();
            window.add_project (p);
            window.add_file (f);

            window.show ();
            Gtk.main ();
        }

        public static int main (string[] args)
        {
            Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
            Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
            Intl.textdomain (Config.GETTEXT_PACKAGE);

            var app = get_default ();
            return app.run (args);
        }
    }
}