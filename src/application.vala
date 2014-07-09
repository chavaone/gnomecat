/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of GNOMECAT
 *
 * Copyright (C) 2013 - Marcos Chavarría Teijeiro
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

using Gtk;
using GNOMECAT.UI;
using GNOMECAT.FileProject;
using Gee;

namespace GNOMECAT
{
    public class Application : Gtk.Application
    {
        private ArrayList<FileOpener> file_openers;
        private GNOMECAT.PluginManager manager;
        private static GNOMECAT.Application _instance;

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

        private GNOMECAT.Profiles.Profile? _enabled_profile;
        public GNOMECAT.Profiles.Profile? enabled_profile
        {
            get
            {
                GLib.Settings prof_set = new GLib.Settings ("org.gnome.gnomecat.ProfilesList");
                if (_enabled_profile == null)
                {
                    string prof_uuid = prof_set.get_string ("default");
                    _enabled_profile = prof_uuid == "" ? null : new GNOMECAT.Profiles.Profile.from_uuid (prof_uuid);
                }
                return _enabled_profile;
            }
            set
            {
                GLib.Settings prof_set = new GLib.Settings ("org.gnome.gnomecat.ProfilesList");
                _enabled_profile = value;
                prof_set.set_string ("default", value == null ? "" : value.uuid);
            }
        }

        const GLib.ActionEntry[] action_entries = {
            { "quit", on_quit }
        };

        const GNOMECAT.Accel[] accel_entries = {
            { "win.edit-undo", "<Control>Z" },
            { "win.edit-redo", "<Control>Y" },
            { "win.search-next", "<Control>H" },
            { "win.search-previous", "<Control>G" },
            { "win.edit-save", "<Control>S"},
            { "win.go-next", "<Control>K"},
            { "win.go-previous", "<Control>J"},
            { "win.go-next-untranslated", "<Control>I"},
            { "win.go-previous-untranslated", "<Control>U"},
            { "win.go-next-translated", "<Control>P"},
            { "win.go-previous-translated", "<Control>O"},
            { "win.go-next-fuzzy", "<Control>y"},
            { "win.go-previous-fuzzy", "<Control>t"},
            { "win.done", "<Control>D"},
            { "win.back", "Escape"},
            { "win.search", "<Control>F"}
        };


        public signal void provide_hints (GNOMECAT.FileProject.Message m, GNOMECAT.HintViewer hv);
        public signal void check_message (GNOMECAT.FileProject.Message m);

        private Application ()
        {
            Object (application_id: "org.gnome.gnomecat",
                flags: ApplicationFlags.HANDLES_OPEN);
        }

        construct
        {
            file_openers = new ArrayList<FileOpener> ();
            add_opener (new GNOMECAT.PoFiles.PoFileOpener ());
            this.window_removed.connect (on_window_removed);

            manager = new PluginManager (this);

            // -------------------------------
            // ------------ DEMO -------------
            // -------------------------------

            provide_hints.connect ((m, hv) => {
                GNOMECAT.Hint h = new Hint (m.get_original_singular (), "DEMO", 0.3);
                hv.display_hint (m, h);
            });

            check_message.connect ((m) => {
                int random;
                if (m.state != MessageState.UNTRANSLATED)
                {
                    random = Random.int_range (0,9);
                    for (int i = 0; i < random; i++)
                    {
                        int n = Random.int_range (0,3);
                        m.add_tip (
                            new MessageTip (
                                "Just a tip",
                                "fkldsajlfkjdalkdfjalksdjflñ",
                                n == 0 ? TipLevel.INFO :
                                n == 1 ? TipLevel.WARNING :
                                TipLevel.ERROR,
                                null,
                                null));
                    }
                }

                });

            add_action_entries (action_entries, this);
            add_accel_entries (accel_entries);

        }

        private void add_accel_entries (Accel[] entries)
        {
            foreach (var accel in entries)
            {
                add_accelerator(accel.accel, accel.name, null);
            }
        }

        public static new GNOMECAT.Application get_default ()
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

        public GNOMECAT.FileProject.File? open_file (string path)
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

        private void on_window_removed ()
        {
            foreach (var w in get_windows ())
                return;
            quit ();
        }

        public override void activate ()
        {
            GNOMECAT.UI.Window window = new GNOMECAT.UI.Window (this);

            if (enabled_profile == null)
            {
                window.set_panel(WindowStatus.OTHER, new GNOMECAT.UI.WelcomePanel());
            }
            else
            {
                window.set_panel(WindowStatus.OPENEDFILES);
            }

            window.show ();
        }

        public override void open (GLib.File[] files, string hint)
        {
            GNOMECAT.UI.Window window = new GNOMECAT.UI.Window (this);

            foreach (GLib.File f in files)
            {
                GNOMECAT.FileProject.File file = open_file (f.get_path ());
                if (file != null)
                    window.file = file;
                else
                    stderr.printf ("Error while open %s file.\n", f.get_path ());
            }

            window.show ();
        }

        public override void startup ()
        {
            base.startup ();

            initialize_workaround ();

            var css_provider = new Gtk.CssProvider ();
            try {
                var file = GLib.File.new_for_uri("resource:///org/gnome/gnomecat/css/gnomecat.css");
                css_provider.load_from_file (file);
            } catch (Error e) {
                warning ("loading css: %s", e.message);
            }
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default(),
                css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            var builder = new Gtk.Builder ();
            try {
                builder.add_from_resource ("/org/gnome/gnomecat/ui/appmenu.ui");
            } catch (Error e) {
                error ("loading main builder file: %s", e.message);
            }
            var app_menu = builder.get_object ("appmenu") as MenuModel;
            set_app_menu (app_menu);
        }


        //This is a workaround to be able to use custom templates inside another templates.
        private void initialize_workaround ()
        {
            new GNOMECAT.UI.SearchBar();
            new GNOMECAT.UI.MessageListWidget();
            new GNOMECAT.UI.HintPanelWidget();
            new GNOMECAT.UI.ToolBar();
            new GNOMECAT.UI.OpenedFilesPanel();
            new GNOMECAT.UI.MessageEditor ();
            new GNOMECAT.UI.EditPanel();
            new PeasGtk.PluginManagerView (null);
            new GNOMECAT.UI.PreferencesPanel();
            new GNOMECAT.PluralForm (0, 0, "", new Gee.HashMap<int, string>());
            new GNOMECAT.Language ("", "", -1, "");
            new GNOMECAT.UI.RecentFilesWidget ();
            new GNOMECAT.UI.OpenFilePanel();
        }

        public void on_quit ()
        {
            foreach (var w in get_windows ())
                w.destroy();
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