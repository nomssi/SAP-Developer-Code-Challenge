CLASS zcl_axage_wizard_ui DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA command TYPE string.
    DATA results TYPE string.
    DATA help TYPE string.
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
      descr = 'a giant welding torch in the corner' ).
    attic->things->add( welding_torch ).


    engine->player->set_location( living_room ).

  ENDMETHOD.

  METHOD execute.
    DATA(result) = engine->interprete( command ).

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
      init_game(  ).
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
      shownavbutton  = abap_true
    ).


    page->header_content(
      )->overflow_toolbar(
        )->button(
            text  = 'Look'
            press = client->_event( 'LOOK' )
            icon  = 'sap-icon://show'
            type  = 'Emphasized'
        )->button( text = 'Inventary'
                   press = client->_event( 'INV' )
                   icon = 'sap-icon://menu'
        )->button(
             text = 'Map'
             press = client->_event( 'MAP' )
             icon  = 'sap-icon://map-2'
        )->button(
            text  = 'Take'
            press = client->_event( 'TAKE' )
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
            )->label( 'Command'
            )->input( client->_bind( command )
            )->button(
                text  = 'Execute Command'
                press = client->_event( 'BUTTON_POST' ) ).

    page->grid( 'L8 M8 S8' )->content( 'layout' ).
    grid->simple_form( title = 'Game Console' editable = abap_true )->content( 'form'
        )->code_editor( value = client->_bind( results ) editable = 'false' type = `plain_text`
                      height = '600px'
        )->text_area( value = client->_bind( help ) editable = 'false' growingmaxlines = '40' growing = abap_True
                      height = '600px'
        ).
    client->set_next( VALUE #( xml_main = page->get_root( )->xml_get( ) ) ).

  ENDMETHOD.
ENDCLASS.
