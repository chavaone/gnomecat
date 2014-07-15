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

using GNOMECAT.Profiles;
using Gee;

namespace GNOMECAT.UI
{
    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/preferencespanel.ui")]
    public class PreferencesPanel : Gtk.Stack, GNOMECAT.UI.Panel
    {

        private Settings settings;

        [GtkChild]
        private Gtk.CheckButton highlight_checkbutton;
        [GtkChild]
        private Gtk.CheckButton visible_whitespace_checkbutton;
        [GtkChild]
        private Gtk.CheckButton use_custom_font_checkbutton;
        [GtkChild]
        private Gtk.FontButton editor_font_fontbutton;
        [GtkChild]
        private Gtk.Box editor_font_hbox;
        [GtkChild]
        private Gtk.ComboBoxText changed_state;
        [GtkChild]
        private Gtk.ListBox profiles_list;

        public GNOMECAT.UI.Window window
        {
            get
            {
                return get_parent ().get_parent ().get_parent () as GNOMECAT.UI.Window;
            }
        }

        public GNOMECAT.UI.ToolBarMode toolbarmode
        {
            get
            {
                return GNOMECAT.UI.ToolBarMode.COMPLETE;
            }
        }

        public int window_page {get; set;}

        public void reload_data ()
        {

            settings = new Settings ("org.gnome.gnomecat.Editor");

            highlight_checkbutton.active = settings.get_boolean ("highlight");
            visible_whitespace_checkbutton.active = settings.get_boolean ("visible-whitespace");
            editor_font_fontbutton.font = settings.get_string ("font");
            editor_font_hbox.sensitive = settings.get_boolean ("custom-font");
            changed_state.active_id = settings.get_string ("message-changed-state");

            settings.bind ("highlight", highlight_checkbutton, "active",  SettingsBindFlags.DEFAULT);
            settings.bind ("visible-whitespace", visible_whitespace_checkbutton, "active",  SettingsBindFlags.DEFAULT);
            settings.bind ("font", editor_font_fontbutton, "font", SettingsBindFlags.DEFAULT);
            settings.bind ("custom-font", use_custom_font_checkbutton, "active", SettingsBindFlags.DEFAULT);
            settings.bind ("custom-font", editor_font_hbox, "sensitive", SettingsBindFlags.DEFAULT);
            settings.bind ("message-changed-state", changed_state, "active_id", SettingsBindFlags.DEFAULT);


            ArrayList<Profile> profs = GNOMECAT.Profiles.Profile.get_profiles ();
            profiles_list.forall((w) => {profiles_list.remove(w);});
            foreach (Profile p in profs)
                profiles_list.add (new ProfileRow (p));
        }

        [GtkCallback]
        private void on_create_profile ()
        {
            (window.window_panels.get_nth_page (WindowStatus.PROFILE) as SimpleProfilePanel).profile = null;
            window.set_panel (WindowStatus.PROFILE);
        }

        [GtkCallback]
        private void on_remove_profile ()
        {
            if (GNOMECAT.Profiles.Profile.get_profiles ().size == 1)
            {
                //TODO: display message.
                return;
            }

            (profiles_list.get_selected_row () as ProfileRow).profile.remove ();
            reload_data ();
        }

        [GtkCallback]
        private void on_enable_profile ()
        {
            ProfileRow pr = (profiles_list.get_selected_row () as ProfileRow);

            if (pr != null)
            {
                pr.profile.enabled = true;
            }
            reload_data ();
        }

        public void on_done (GNOMECAT.UI.Window window)
        {
            window.set_panel(window.last_page);
        }

        public void on_preferences (GNOMECAT.UI.Window window)
        {}

        public void setup_headerbar (GNOMECAT.UI.ToolBar toolbar)
        {
            toolbar.mode = toolbarmode;
            toolbar.stack_switch.stack = this;
            toolbar.stack_switch.visible = true;
            toolbar.done_btn.visible = true;
            toolbar.back_btn.visible = false;
        }
    }


    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/profilerow.ui")]
    public class ProfileRow : Gtk.ListBoxRow
    {

        public Profile profile {get; private set;}
        [GtkChild]
        private Gtk.Label profile_name;
        [GtkChild]
        private Gtk.Label language_code;
        [GtkChild]
        private Gtk.Label enabled;

        public string profile_name_entry_text
        {
            get
            {
                return profile_name.get_text ();
            }
            set
            {
                profile_name.set_text (value);
            }
        }

        public string language_code_entry_text
        {
            get
            {
                return language_code.get_text ();
            }
            set
            {
                language_code.set_text (value);
            }
        }

        public bool enabled_profile
        {
            get
            {
                return enabled.get_text () == _("(enabled)");
            }
            set
            {
                enabled.set_text(value ? _("(enabled)") : "");
            }
        }

        public GNOMECAT.UI.Window window
        {
            get
            {
                return GNOMECAT.Application.get_default ().get_active_window () as GNOMECAT.UI.Window;
            }
        }

        public ProfileRow (Profile p)
        {
            profile = p;
            profile_name_entry_text = p.name;
            language_code_entry_text = p.language_code;
            enabled.visible = p.enabled;
            this.bind_property ("profile_name_entry_text", profile, "name",
                BindingFlags.BIDIRECTIONAL);
            this.bind_property ("language_code_entry_text", profile, "language_code",
                BindingFlags.BIDIRECTIONAL);
            profile.bind_property ("enabled", this, "enabled_profile");
        }

        [GtkCallback]
        private void on_edit_profile ()
        {
            (window.window_panels.get_nth_page (WindowStatus.PROFILE) as SimpleProfilePanel).profile = profile;
            window.set_panel (WindowStatus.PROFILE);
        }
    }
}