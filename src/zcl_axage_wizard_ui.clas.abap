CLASS zcl_axage_wizard_ui DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA command TYPE string.
    DATA auto_look TYPE xsdboolean.
    DATA anzahl_items TYPE string VALUE '0'.
    DATA results TYPE string.
    DATA help TYPE string.
    DATA help_html TYPE string.

    TYPES:
      BEGIN OF ts_suggestion_items,
        value TYPE string,
        descr TYPE string,
      END OF ts_suggestion_items.

    DATA mt_suggestion TYPE STANDARD TABLE OF ts_suggestion_items WITH EMPTY KEY.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA engine TYPE REF TO zcl_axage_engine.
    DATA check_initialized TYPE abap_bool.
    METHODS init_game.
    METHODS execute IMPORTING command TYPE string.
ENDCLASS.



CLASS zcl_axage_wizard_ui IMPLEMENTATION.


  METHOD init_game.
    engine = NEW #( ).
    " Nodes
    DATA(living_room) = NEW zcl_axage_room( name = 'Living Room' descr = 'the living-room of a wizard''s house.' ).
    DATA(attic)  = NEW zcl_axage_room( name = 'Attic'  descr = 'the attic.' ).
    DATA(garden) = NEW zcl_axage_room( name = 'Garden'  descr = 'a beautiful garden.' ).

    engine->map->add_room( living_room ).
    engine->map->add_room( attic ).
    engine->map->add_room( garden ).
    engine->map->set_floor_plan( VALUE #(
      ( `+--------------------+` )
      ( `| Welding Torch      |` )
      ( `|                    |` )
      ( `|        ATTIC       |` )
      ( `|                    |` )
      ( `+--------+  +--------+` )
      ( `         |__| ` )
      ( `  Ladder |  | ` )
      ( `+--------+  +--------+ +----------------+` )
      ( `|              Bucket| | Frog           |` )
      ( `|     LIVING         | |      Well      |` )
      ( `|      ROOM          +-+                |` )
      ( `|                    Door    GARDEN     |` )
      ( `|  Sleeping          +-+                |` )
      ( `|   Wizard   Whiskey | |         Chain  |` )
      ( `+--------------------+ +----------------+` )
       ) ).

    living_room->set_exits(
      u = attic
      e = garden ).
    attic->set_exits(
      d = living_room ).
    garden->set_exits(
      w = living_room ).
    DATA(wizard) = NEW zcl_axage_thing( name = 'WIZARD' descr = 'snoring loudly on the couch' ).
    living_room->things->add( wizard ).
    DATA(whiskey) = NEW zcl_axage_thing( name = 'BOTTLE' descr = 'whiskey on the floor' ).
    living_room->things->add( whiskey ).
    DATA(bucket) = NEW zcl_axage_thing( name = 'BUCKET' descr = 'on the floor' ).
    living_room->things->add( bucket ).

    DATA(well) = NEW zcl_axage_thing( name = 'WELL' descr = 'in front of you' ).
    garden->things->add( well ).
    DATA(frog) = NEW zcl_axage_thing( name = 'FROG' descr = 'on the floor' ).
    garden->things->add( frog ).
    DATA(chain) = NEW zcl_axage_thing( name = 'CHAIN' descr = 'on the floor' ).
    garden->things->add( chain ).

    DATA(welding_torch) = NEW zcl_axage_thing( name = 'WELDING TORCH'
      descr = 'in the corner' ).
    attic->things->add( welding_torch ).


    engine->player->set_location( living_room ).

    mt_suggestion = VALUE #(
        ( descr = 'Display help text'  value = 'HELP' )
        ( descr = 'Go to the room on the north side'   value = 'NORTH' )
        ( descr = 'Go to the room on the south side'  value = 'SOUTH' )
        ( descr = 'Go to the room on the east side'   value = 'EAST' )
        ( descr = 'Go to the room on the west side'  value = 'WEST' )
        ( descr = 'Go to the room on the upstairs'    value = 'UP' )
        ( descr = 'Go to the room on the downstairs'   value = 'DOWN' )
        ( descr = 'Show Map/floor plan/Game world'  value = 'MAP' )

        ( descr = 'Inventary - Show everything you carry'  value = 'INVENTORY' )

        ( descr = 'What is in the room?' value = 'LOOK' )
        ( descr = 'Look <object>'       value = 'LOOK' )
        ( descr = 'Pickup <object>'  value = 'PICKUP' )
        ( descr = 'Drop <object>'  value = 'DROP' )
        ( descr = 'Open <object>'  value = 'OPEN' )
        ( descr = 'Ask <person>'  value = 'ASK' )
        ( descr = 'Weld <subject> <object>'  value = 'WELD' )

        ( descr = 'Dunk <subject> <object>'  value = 'DUNK' )
        ( descr = 'Splash <subject> <object>'  value = 'SPLASH' )
         ).

     help_html =
      |<h2>Help</h2><p>| &
      |<h3>Navigation Commands</h3><ul>| &&
      |<li>MAP        <em>Show map/ floor plan/ world</em>| &&
      |<li>N or NORTH <em>Walk to the room on the north side</em>| &&
      |<li>E or EAST  <em>Walk to the room on the east side</em>| &&
      `<li>S or SOUTH <em>Walk to the room on the south side</em>` &&
      `<li>W or WEST  <em>Walk to the room on the west side</em>` &&
      `<li>U or UP    <em>Go to the room upstairs</em>` &&
      `<li>D or DOWN  <em>Go to the room downstairs</em></ul><p>`.

      help_html = help_html &&
      |<h3>Interaction with Objects</h3>| &&
      |<ul><li>INV or INVENTORY <em>View everything you ae carrying</em>| &&
      `<li>LOOK <em>Describe your environment</em>` &&
      `<li>LOOK object     <em>Have a closer look at the object in the room or in your inventory</em>` &&
      `<li>PICKUP object   <em>Pickup an object in the current place</em>` &&
      `<li>DROP object     <em>Drop an object that you carry</em>` &&
      `<li>OPEN object     <em>Open something that is in the room</em></ul><p>`.

      help_html = help_html &&
      |<h3>Other Commands</h3><ul>| &&
      `<li>ASK person            <em>Ask a person to tell you something</em>` &&
      `<li>WELD subject object   <em>Weld subject to the object if allowed</em>` &&
      `<li>DUNK subject object   <em>Dunk subject into object if allowed</em>` &&
      `<li>SPLASH subject object <em>Splash  subject into object</em></ul>`.

  ENDMETHOD.

  METHOD execute.
    DATA(result) = engine->interprete( command = command
                                       auto_look = auto_look ).
    anzahl_items = lines( engine->player->things->get_list( ) ).

    IF engine->player->location->things->exists( 'RFC' ).
      engine->mission_completed = abap_true.
      result->add( 'Congratulations! You delivered the RFC to the developers!' ).
    ENDIF.

    results = |You are in { engine->player->location->description }.\n| && result->get(  ).
  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    IF check_initialized = abap_false.
      check_initialized = abap_true.
      command = 'MAP'.
      init_game( ).
      help = engine->interprete( 'HELP' )->get( ).

    ENDIF.

    CASE client->get( )-event.
      WHEN 'LOOK' OR 'INV' OR 'MAP' OR 'UP'
        OR 'DOWN' OR 'NORTH' OR 'SOUTH' OR 'EAST' OR 'WEST'
        OR 'HELP'.
        execute( client->get( )-event ).

      WHEN 'BUTTON_POST'.
        client->popup_message_toast( |{ command } - send to the server| ).
        execute( command ).

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack  ) ).
    ENDCASE.

    DATA(view) = z2ui5_cl_xml_view=>factory( )->shell( ).
    DATA(page) = view->page(
      id =           'id_page'
      title          = 'abap2UI5 and AXAGE - The Wizard''s Adventure Game'
      navbuttonpress = client->_event( 'BACK' )
      shownavbutton  = abap_true ).

    page->header_content(
      )->overflow_toolbar(
        )->button(
            text  = 'Look'
            press = client->_event( 'LOOK' )
            icon  = 'sap-icon://show'
            type  = 'Emphasized'
        )->button(
             text = 'Map'
             press = client->_event( 'MAP' )
             icon  = 'sap-icon://map-2'
        )->toolbar_spacer(

        )->button(
             text = 'UP'
             press = client->_event( 'UP' )
             icon  = 'sap-icon://arrow-top'
        )->button(
             text = 'DOWN'
             press = client->_event( 'DOWN' )
             icon  = 'sap-icon://arrow-bottom'
        )->button(
             text = 'North'
             press = client->_event( 'NORTH' )
             icon  = 'sap-icon://navigation-up-arrow'
        )->button(
             text = 'South'
             press = client->_event( 'SOUTH' )
             icon  = 'sap-icon://navigation-down-arrow'
        )->button(
             text = 'West'
             press = client->_event( 'WEST' )
             icon  = 'sap-icon://navigation-left-arrow'
        )->button(
             text = 'East'
             press = client->_event( 'EAST' )
             icon  = 'sap-icon://navigation-right-arrow'

        )->button(
             text = 'Help'
             press = client->_event( 'HELP' )
             icon  = 'sap-icon://sys-help'
       )->get_parent( ).

    DATA(grid) = page->grid( 'L12 M12 S12' )->content( 'layout' ).
    grid->simple_form(
        title =  'abap2UI5 and AXAGE - The Wizard''s Adventure Game'
        editable = abap_true
        )->content( 'form'
            )->label( 'Always Look'
              )->switch(
              state         = client->_bind( auto_look )
              customtexton  = 'Yes'
              customtextoff = 'No'
            )->button(
                text  = 'Execute Command'
                press = client->_event( 'BUTTON_POST' )
            )->label( 'Command'
            )->input(
                    showClearIcon   = abap_true

                    value           = client->_bind( command )
                    placeholder     = 'enter your next command'
                    suggestionitems = client->_bind_one( mt_suggestion )
                    showsuggestion  = abap_true )->get(

                        )->suggestion_items( )->get(
                           )->list_item(
                               text = '{VALUE}'
                               additionaltext = '{DESCR}' ).

    page->grid( 'L8 M8 S8' )->content( 'layout' ).
    grid->simple_form( title = 'Game Console' editable = abap_true )->content( 'form'
        )->code_editor( value = client->_bind( results )
                        editable = 'false'
                        type = `plain_text`
                        height = '600px'
         )->vbox( 'sapUiSmallMargin'
                )->formatted_text( help_html
*        )->text_area( value = client->_bind( help )
*                      editable = 'false'
*                      growingmaxlines = '40'
*                      growing = abap_True
*                      height = '600px'
       ).

    page->footer(
            )->overflow_toolbar(
        )->button(
            text  = 'Pickup'
            press = client->_event( 'PICKUP' )
            enabled = abap_false
            icon = 'sap-icon://cart-3'
        )->button(
            text  = 'Drop'
            press = client->_event( 'DROP' )
            enabled = abap_false
            icon = 'sap-icon://cart-2'
        )->button(
            text  = 'Open'
            press = client->_event( 'OPEN' )
            enabled = abap_false
            icon = 'sap-icon://outbox'
        )->button(
            text  = 'Ask'
            press = client->_event( 'ASK' )
            enabled = abap_false
            icon = 'sap-icon://travel-request'
*        )->button(
*            text  = 'Weld'
*            press = client->_event( 'WELD' )
*            enabled = abap_true
                )->button( text = 'Inventory'
                           class = 'sapUiTinyMarginBeginEnd'
                           press = client->_event( 'INV' )
                           icon = 'sap-icon://menu'  " 'sap-icon://cart'
                     )->get( )->custom_data(
                                )->badge_custom_data(
                                    key     = 'items'
                                    value   = anzahl_items
                                    visible = abap_true
                )->get_parent( )->get_parent(

                )->toolbar_spacer(
        )->link(
             text = 'Credits'
             href  = 'http://landoflisp.com' ).
    client->set_next( VALUE #( xml_main = page->get_root( )->xml_get( ) ) ).
  ENDMETHOD.
ENDCLASS.
