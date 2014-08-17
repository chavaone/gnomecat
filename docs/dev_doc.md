GNOMECAT
========

GNOMECAT is a l10n files editor (currently only supports gettext .po files). The main goal of this project is to write a extensible tool for GNOME translators.


Developers Documentation
========================

=== Messages, Files and Project ===

We have build a system to deal with files that tries to be extensible and allow to work with files different from gettext po files.

Localization files have a serie of strings that should be translated from the source language (usually English) to the final language. Each string that has to be translated is a GNOMECAT.Message in the program. This \\abstract\\ class has methods to retrieve both original and translation files and methods to set the translations. Each message has some origins that indicate where the string is located in the code. In addition a message has an state that could be TRANSLATED, UNTRANSLATED or FUZZY.

A file contains messages and statistics about messages in addition it contains a way to get and to set additional info from from files as a key-value map. It contains abstract methods to parse and save files.

A project is a set of files. (I still have not develop this concept so much.).


=== Tips and Hints ===

A tip is an error or an advice about a translation of a message. It has 3 different levels INFO, WARNING and ERROR. In addition a tip have a set of TextTags that can hightlight certain parts of the message.

A hint is a posible translation of a message. It could be provided from different sources as Translation Memory, the file that is being translated, files of other languages, etc.


=== UI ===

The UI consists in a window with a Gtk.Headerbar, a Gtk.InfoBar and a Gtk.Notebook. The notebook contains panels that show the different screens of the application (preferences, edit file, open file, opened files list, etc.). The infobar is useful for displaying information about the program. The headerbar changes depending on the panel that is enabled.

A Panel is a widget that implements GNOMECAT.UI.Panel interface. This interface implements a state pattern and it haves empty implementation for many methods that will receive a proper implementation in each class. We have implemented the following panels:

 * WelcomePanel
 * OpenFilePanel
 * OpenedFilesPanel
 * PreferencesPanel
 * ProfilePanel
 * FirstProfilePanel
 * EditPanel

 ==== Edit Panel ====

 The most complex panel is the edit panel. It contains a widget with a list of files, a widget with a list of hints, a widget with a list of tips, a notebook to edit the different plural forms of each message and some buttons.

 The list of files is a treeview with a custom CellRenderer called GNOMECAT.UI.CellRenderer. This list of files can be sorted of filtered following files state.

 Thi list of tips and hints are Gtk.Listbox'es with custom rows.

=== Search and Navigation ===

The navigation system allows the user to navigate to the next/previous message or to the next message with a certain state. We do this analicing in order the items from the treeview model and selecting the first ocurrence that follows the criteria.

For search we have implement a file iterator that iterates on file messages and a MessageIterator that iterates on GNOMECAT.MessageFragment. A message fragment is a class that indicates certain part of a message.