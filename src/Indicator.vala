/*-
 * Copyright (c) 2015 Wingpanel Developers (http://launchpad.net/wingpanel)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

public class Drop.Indicator : Wingpanel.Indicator {
	private Drop.Session session;

	private Gtk.Label display_icon;
	private Gtk.Grid main_grid;

	public Indicator () {
		Object (code_name: "Wingpanel-Indicator-Drop",
				display_name: _("Drop"),
				description:_("The drop indicator"));
	}

	public override Gtk.Widget get_display_widget () {
		if (display_icon == null) {
			display_icon = new Gtk.Label ("D");
		}
		
		return display_icon;
	}

	public override Gtk.Widget? get_widget () {
		if (main_grid == null) {
			main_grid = new Gtk.Grid ();
			main_grid.orientation = Gtk.Orientation.VERTICAL;
			session = new Drop.Session ();

			session.new_incoming_transmission.connect ((transmission) => {
				debug ("Requesting Transmition\n");
				var widget = new Drop.Widgets.IncomingTransmission (transmission);
				widget.margin = 4;

				main_grid.add (widget);
				widget.visible = true;
			});
			
			session.new_outgoing_transmission.connect ((transmission) => {
				debug ("Requesting Transmition\n");
				var widget = new Drop.Widgets.OutgoingTransmission (transmission);
				widget.margin = 4;

				main_grid.add (widget);
				widget.visible = true;
			});

		}
		visible = true;
		return main_grid;
	}

	public override void opened () {}

	public override void closed () {}

}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
	// Temporal workarround for Greeter crash
	if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION)
		return null;
	debug ("Activating Keyboard Indicator");
	var indicator = new Drop.Indicator ();
	return indicator;
}
