/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of GnomeCAT
 *
 * Copyright (C) 2013 - Marcos Chavarría Teijeiro
 *
 * GnomeCAT is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * GnomeCAT is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with GnomeCAT. If not, see <http://www.gnu.org/licenses/>.
 */

using Gtk;
using GnomeCAT.UI;
using GnomeCAT.FileProject;
using Gee;

namespace GnomeCAT
{
    public class Application : Gtk.Application
    {
        private ArrayList<FileOpener> file_openers;
        private ArrayList<HintProvider> hint_providers;
        private ArrayList<Checker> checkers;
        private static GnomeCAT.Application _instance;

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

        private GnomeCAT.Profiles.Profile? _enabled_profile;
        public GnomeCAT.Profiles.Profile? enabled_profile
        {
            get
            {
                GLib.Settings prof_set = new GLib.Settings ("info.aquelando.gnomecat.ProfilesList");
                if (_enabled_profile == null)
                {
                    string prof_uuid = prof_set.get_string ("default");
                    _enabled_profile = prof_uuid == "" ? null : new GnomeCAT.Profiles.Profile.from_uuid (prof_uuid);
                }
                return _enabled_profile;
            }
            set
            {
                GLib.Settings prof_set = new GLib.Settings ("info.aquelando.gnomecat.ProfilesList");
                _enabled_profile = value;
                prof_set.set_string ("default", value == null ? "" : value.uuid);
            }
        }

        private Application ()
        {
            Object (application_id: "info.aquelando.gnomecat",
                flags: ApplicationFlags.HANDLES_OPEN);
        }

        construct
        {
            file_openers = new ArrayList<FileOpener> ();
            add_opener (new GnomeCAT.PoFiles.PoFileOpener ());
            this.window_removed.connect (on_window_removed);

            hint_providers = new ArrayList<HintProvider> ();
            add_hint_provider (new GnomeCAT.Demo.DemoHintProvider ()); //DEMO

            checkers = new ArrayList<Checker> ();
            add_checker (new GnomeCAT.Demo.DemoChecker ()); //DEMO
        }

        public static new GnomeCAT.Application get_default ()
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

        public GnomeCAT.FileProject.File? open_file (string path)
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

        public void get_hints (GnomeCAT.FileProject.Message m,
            GnomeCAT.UI.HintPanelWidget pannel)
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

        public void select (GnomeCAT.SelectLevel level,
            GnomeCAT.FileProject.MessageFragment? fragment)
        {
            bool success = false;
            foreach (var w in get_windows ())
            {
                success |= (w as GnomeCAT.UI.Window).select(level, fragment);
            }

            if (!success && fragment.file != null)
            {
                GnomeCAT.FileProject.File file = open_file (fragment.file.path);
                if (file != null)
                    (get_active_window () as GnomeCAT.UI.Window).add_file (file);
                else
                    stderr.printf ("Error while open %s file.\n", fragment.file.path);
            }
        }

        public void deselect (GnomeCAT.SelectLevel level,
            GnomeCAT.FileProject.MessageFragment? fragment)
        {
            foreach (var w in get_windows ())
            {
                (w as GnomeCAT.UI.Window).deselect(level, fragment);
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
            GnomeCAT.UI.Window window = new GnomeCAT.UI.Window (this);
            window.show ();
            Gtk.main ();
        }

        public override void open (GLib.File[] files, string hint)
        {
            GnomeCAT.UI.Window window = new GnomeCAT.UI.Window (this);

            foreach (GLib.File f in files)
            {
                GnomeCAT.FileProject.File file = open_file (f.get_path ());
                if (file != null)
                    window.add_file (file);
                else
                    stderr.printf ("Error while open %s file.\n", f.get_path ());
            }

            //DEMO
            GnomeCAT.FileProject.Project p = new Project ("/home/ch01");
            GnomeCAT.FileProject.File f = new GnomeCAT.Demo.DemoFile ();
            window.add_project (p);
            window.add_file (f);

            window.show ();
            Gtk.main ();
        }

        public override void startup ()
        {
            base.startup ();

            var css_provider = new Gtk.CssProvider ();
            try {
                var file = GLib.File.new_for_uri("resource:///info/aquelando/gnomecat/css/gnomecat.css");
                css_provider.load_from_file (file);
            } catch (Error e) {
                warning ("loading css: %s", e.message);
            }
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default(),
                css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
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