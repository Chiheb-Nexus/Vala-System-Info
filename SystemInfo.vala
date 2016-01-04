/*
*
* System Info - Vala
* Author: Chiheb NeXus - 2016
* Blog: www.nexus-coding.blogspot.com
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 3 of the License.
*
* This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*  
*  You should have received a copy of the GNU General Public License
*  along with this program; if not, write to the Free Software
*  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
*  MA 02110-1301, USA. 
*
*
*/

using Gtk;
using Gdk;

class SystemInfo: Gtk.Window{

	// Déclaration de textview
	private Gtk.TextView textview = new Gtk.TextView();
	private Gtk.Label status = new Gtk.Label("");

	// Constructeur de notre classe
	public SystemInfo(){

		// Création de l'interface avec Gtk.Builder()
		try{
			var builder = new Builder();
			// window-vala.ui : doit être dans le même dossier avec System.info.vala
			// lors de la compilation
			builder.add_from_file("window-vala.ui");
			var window = builder.get_object("main_window") as Gtk.Window;
			window.destroy.connect(()=> {
				stdout.printf("Safe destroy ... \n");
				Gtk.main_quit();
				});
			// TextView
			textview = builder.get_object("main_textview") as TextView;
			// Status label
			status = builder.get_object("label_status") as Label;
			// Tous les autres bouttons
			var kernel_version = builder.get_object("button_kernel_version") as Button;
			var lsb_release = builder.get_object("button_lsb") as Button;
			var cpuinfo = builder.get_object("button_cpuinfo") as Button;
			var lscpu = builder.get_object("button_lscpu") as Button;
			var meminfo = builder.get_object("button_meminfo") as Button;
			var lsusb = builder.get_object("button_lsusb") as Button;
			var lspci = builder.get_object("button_lspci") as Button;
			var lsblk = builder.get_object("button_lsblk") as Button;
			var df = builder.get_object("button_df") as Button;
			var mount = builder.get_object("button_mount") as Button;
			var imagemenuitem = builder.get_object("imagemenuitem") as Gtk.MenuItem;
			var imagemenuitem2 = builder.get_object("imagemenuitem2") as Gtk.MenuItem;
			// Signals
			imagemenuitem.activate.connect(() => {
				quitter();
				});
			imagemenuitem2.activate.connect(() => {
				about_dialog();
				});
			kernel_version.clicked.connect(() =>{
				modify_textview("cat /proc/version");
				});
			lsb_release.clicked.connect(() =>{
				modify_textview("lsb_release -a");
				});
			cpuinfo.clicked.connect(() => {
				modify_textview("cat /proc/cpuinfo");
				});
			lscpu.clicked.connect(() => {
				modify_textview("lscpu");
				});
			meminfo.clicked.connect(() => {
				modify_textview("cat /proc/meminfo");
				});
			lsusb.clicked.connect(() => {
				modify_textview("lsusb");
				});
			lspci.clicked.connect(() => {
				modify_textview("lspci");
				});
			lsblk.clicked.connect(() => {
				modify_textview("lsblk");
				});
			df.clicked.connect(() => {
				modify_textview("df -H");
				});
			mount.clicked.connect(() => {
				modify_textview("mount -l");
				});

			// Tout ajouter à window
			window.show_all();
		} catch (Error e){
			stderr.printf("Could'nt load UI %s\n", e.message);
			Process.exit(0);
		}

	}

	private void modify_textview(string text){

		try{
			string output, error;
			int exit_status;
			Process.spawn_command_line_sync(text, out output, out error, out exit_status);
			textview.buffer.text = output;
			if (exit_status >0){
				textview.buffer.text = error;
			}
			status.use_markup = true;
			status.set_label(@"Dernière commande exécutée: <b><i>$text</i> </b> || exit_status = <b><i>$exit_status</i></b>");
		} catch (SpawnError e){
			textview.buffer.text = e.message;
		}
	}

	private void about_dialog(){
		const string author = "Chiheb NeXus";
		Gtk.AboutDialog dialog = new Gtk.AboutDialog();
		dialog.set_modal(true);
		try{
			var mylogo = new Pixbuf.from_file("logo.png");
			dialog.logo = mylogo;
			} catch( Error e){
				stdout.printf("%s",e.message);
				}
		dialog.artists = {author};
		dialog.authors = {author};
		dialog.program_name = "System Info";
		dialog.comments = "Chiheb NeXus";
		dialog.copyright = "Copyright © 2015-2016 Chiheb NeXus";
		dialog.version = "0.0.1";
		dialog.license = "This program is free software; you can redistribute it and/or modify"+
		"it under the terms of the GNU General Public License as published by"+
		"the Free Software Foundation; either version 3 of the License."+
		"This program is distributed in the hope that it will be useful,"+
		"but WITHOUT ANY WARRANTY; without even the implied warranty of"+
		"MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"+
		"GNU General Public License for more details."+
		"You should have received a copy of the GNU General Public License"+
		"along with this program; if not, write to the Free Software"+
		"Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,"+
		"MA 02110-1301, USA.";
		dialog.wrap_license = true;
		dialog.website = "http://nexus-coding.blogspot.com";
		dialog.website_label = "Nexus Coding.";

		dialog.response.connect ((response_id) => {
			if (response_id == Gtk.ResponseType.CANCEL || response_id == Gtk.ResponseType.DELETE_EVENT) {
				dialog.hide_on_delete ();
				}
			});
		dialog.present();
	}

	private void run(){
		Gtk.main();
	}

	private void quitter(){
		Gtk.main_quit();
	}

	public static void main(string[] args){
	// Initialisation de Gtk
	Gtk.init(ref args);
	var my_window = new SystemInfo();
	my_window.run();
	}

}