CLASS zcl_axage_wizard_ui DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA command TYPE string.
    DATA auto_look TYPE xsdboolean VALUE abap_true.
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

    TYPES:
      BEGIN OF ty_file,
        selkz  TYPE abap_bool,
        name   TYPE string,
        format TYPE string,
        size   TYPE string,
        descr  TYPE string,
        data   TYPE string,
      END OF ty_file.

    DATA mt_file TYPE STANDARD TABLE OF ty_file WITH EMPTY KEY.
    DATA ms_file_prev TYPE ty_file.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA engine TYPE REF TO zcl_axage_engine.
    DATA check_initialized TYPE abap_bool.
    METHODS init_game.
    METHODS execute IMPORTING command TYPE string.
ENDCLASS.



CLASS ZCL_AXAGE_WIZARD_UI IMPLEMENTATION.


  METHOD execute.
    DATA(result) = engine->interprete( command = command
                                       auto_look = auto_look ).
    anzahl_items = lines( engine->player->things->get_list( ) ).

    IF engine->player->location->things->exists( 'RFC' ).
      "AND engine->player->location->name = bill_developer->location->name.

      engine->mission_completed = abap_true.
      result->add( 'Congratulations! You are now member of the Wizard''s Guild' ).
    ENDIF.

    results = |You are in { engine->player->location->description }.\n| && result->get(  ).
  ENDMETHOD.


  METHOD init_game.
    engine = NEW #( ).
    " Nodes
    DATA(living_room) = NEW zcl_axage_room( name = 'Living Room' descr = 'the living-room of a wizard''s house.' ).
    DATA(attic)  = NEW zcl_axage_room( name = 'Attic'  descr = 'the attic.'
       state = 'The attic is dark' ).
    DATA(garden) = NEW zcl_axage_room( name = 'Garden'  descr = 'a beautiful garden.' ).

    engine->map->add_room( living_room ).
    engine->map->add_room( attic ).
    engine->map->add_room( garden ).
    engine->map->set_floor_plan( VALUE #(
      ( `+--------------------+` )
      ( `| Welding            |` )
      ( `|  Torch             |` )
      ( `|                    |` )
      ( `|       ATTIC        |` )
      ( `|                    |` )
      ( `+--------+  +--------+` )
      ( `         |__| ` )
      ( `  Ladder |  | ` )
      ( `+--------+  +--------+ +----------------+` )
      ( `|              Bucket| | Frog           |` )
      ( `|mop                 | |                |` )
      ( `|     LIVING         | |        Well    |` )
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

**LIVING ROOM**:
"- When you **LOOK** around, you find a Fireplace, a Bookshelf, and an Old Painting.
"- When you **LOOK** at the Fireplace, you find Ashes.
"- When you **PICKUP** the Ashes, you obtain them in your **INVENTORY**.
"- When you **LOOK** at the Bookshelf, you find a Magic Tome.
"- When you **PICKUP** the Magic Tome, you learn the spell "Illuminara", which can be used to light up dark places.
"- When you **LOOK** at the Old Painting, you find a depiction of the three magical items you're searching for.


    DATA(wizard) = NEW zcl_axage_thing( name = 'WIZARD' state = 'snoring loudly on the couch' descr = ''
     can_be_pickup = abap_false
     can_be_drop = abap_false
     can_be_splash_into = abap_true
     can_be_dunk_into = abap_false ).
    living_room->things->add( wizard ).

    DATA(whiskey) = NEW zcl_axage_thing( name = 'BOTTLE' state = 'on the floor' descr = 'whiskey'  ).
    living_room->things->add( whiskey ).

    DATA(bucket) = NEW zcl_axage_thing( name = 'BUCKET' state = 'on the floor' descr = ''
     can_be_weld = abap_true
     can_be_splash_into = abap_true
     can_be_dunk_into = abap_true ).
    living_room->things->add( bucket ).

    DATA(mop) = NEW zcl_axage_thing( name = 'MOP' state = 'on the floor' descr = ''
     can_be_dunk_into = abap_true ).
    living_room->things->add( mop ).

    DATA(content_of_fireplace) = NEW zcl_axage_thing_list( ).
    content_of_fireplace->add( NEW zcl_axage_thing( name = 'ASHES'
       descr = 'enchanted ashes'  state = 'from past magical fires'  ) ).

    DATA(needed_to_open_fireplace) = NEW zcl_axage_thing_list(  ).

    DATA(fireplace) = NEW zcl_axage_openable_thing(
      name = 'FIREPLACE'
      descr = 'carved with arcane symbols'
      state = 'its grate is filled with ashes'
      can_be_pickup = abap_false
      can_be_drop = abap_false
      content = content_of_fireplace
      needed  = needed_to_open_fireplace ).
    living_room->things->add( fireplace ).

    DATA(bookshelf_key) = NEW zcl_axage_thing( name = 'KEY' state = '' descr = 'it is small' ).
    living_room->things->add( bookshelf_key ).

    DATA(needed_to_open_tome) = NEW zcl_axage_thing_list( ).

    DATA(content_of_tome) = NEW zcl_axage_thing_list( ).
    content_of_tome->add( NEW zcl_axage_thing( name = 'SPELL' state = ''
       descr = '"Illuminara", which can be used to light up dark places.' ) ).
    DATA(tome) = NEW zcl_axage_openable_thing(
      name    = 'TOME'
      descr   = 'Magic Tome with arcane spells'
      content = content_of_tome
      needed  = needed_to_open_tome ).

    DATA(content_of_bookshelf) = NEW zcl_axage_thing_list( ).
    content_of_bookshelf->add( tome ).

    DATA(needed_to_open_bookshelf) = NEW zcl_axage_thing_list(  ).
    needed_to_open_bookshelf->add( bookshelf_key ).

    DATA(bookshelf) = NEW zcl_axage_openable_thing( name = 'BOOKSHELF'
                           descr = 'with magic tomes'
                           state = 'closed'
                           can_be_open = abap_true
                           can_be_pickup = abap_false
                           can_be_drop = abap_false
                           content = content_of_bookshelf
                           needed  = needed_to_open_bookshelf ).
    living_room->things->add( bookshelf ).

    DATA(painting) = NEW zcl_axage_thing( name = 'PAINTING' state = 'with the title The Guild''s Trial'
       descr = 'depiction of the Orb of Sunlight, the Potion of Infinite Stars, and the Staff of Eternal Moon'
     can_be_pickup = abap_false
     can_be_drop = abap_false ).
    living_room->things->add( painting ).


**GARDEN**:

"- When you **LOOK** around, you find a Pond, a Flower Bed, and a Shed.
"- When you **LOOK** at the Flower Bed, you see a Sunflower.
"- When you **PICKUP** the Sunflower and **WELD** it with the Ashes from the Fireplace, you obtain the Orb of Sunlight.
"- When you **LOOK** at the Pond, you notice that it's too dark to see anything.
"- When you cast "Illuminara" on the Pond, you see a Bottle at the bottom.
"- When you **PICKUP** the Bottle, you discover it's a Potion of Infinite Stars.
"- The Shed is locked. The key can be found in the Attic.

    DATA(pond) = NEW zcl_axage_thing( name = 'POND'
      state = 'it is dark' descr = ''
      can_be_pickup = abap_false
      can_be_drop = abap_false
      can_be_dunk_into = abap_true
      can_be_splash_into = abap_true ).
    garden->things->add( pond ).

    DATA(flower) = NEW zcl_axage_thing( name = 'FLOWER'
      state = 'in a flower bed' descr = 'it is a Sunflower'
      can_be_pickup = abap_false
      can_be_drop = abap_false ).
    garden->things->add( flower ).

    DATA(sched) = NEW zcl_axage_thing( name = 'SCHED'
      state = 'it is locked' descr = ''
      can_be_pickup = abap_false
      can_be_drop = abap_false ).
    garden->things->add( sched ).

    DATA(well) = NEW zcl_axage_thing( name = 'WELL' state = 'in front of you' descr = ''
      can_be_pickup = abap_false
      can_be_drop = abap_false
      can_be_dunk_into = abap_true
      can_be_splash_into = abap_true ).
    garden->things->add( well ).

    DATA(frog) = NEW zcl_axage_thing( name = 'FROG' state = 'on the floor' descr = ''  ).
    garden->things->add( frog ).

    DATA(chain) = NEW zcl_axage_thing( name = 'CHAIN' state = ' the floor' descr = ''
      can_be_weld = abap_true ).
    garden->things->add( chain ).

**ATTIC**:

"- The Attic is dark. Use "Illuminara" to light up the space.
"- When you **LOOK** around, you find a Chest, a Workbench, and a Moon-crested Key.
"- When you **PICKUP** the Moon-crested Key, you can use this to open the Shed in the Garden.
"- When you **OPEN** the Chest, you find an old Magic Staff.
"- When you **PICKUP** the Magic Staff and **DUNK** it into the Potion of Infinite Stars, then **SPLASH** the Orb of Sunlight onto the combined items, you obtain the Staff of Eternal Moon.

    DATA(chest) = NEW zcl_axage_thing( name = 'CHEST' state = ''
      descr = 'on the floor' ).
    attic->things->add( chest ).

    DATA(workbench) = NEW zcl_axage_thing( name = 'WORKBENCH' state = ''
      descr = 'on the corner'
       can_be_pickup = abap_false
       can_be_drop = abap_false ).
    attic->things->add( workbench ).

    DATA(sched_key) = NEW zcl_axage_thing( name = 'BIG KEY' state = 'on the workbench'
      descr = 'it is moon-crested' ).
    attic->things->add( sched_key ).

    DATA(welding_torch) = NEW zcl_axage_thing( name = 'WELDING TORCH' state = ''
      descr = 'in the corner'
       can_weld = abap_true
       can_be_pickup = abap_false
       can_be_drop = abap_false ).
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
        ( descr = 'Cast <spell>'  value = 'CAST' )
        ( descr = 'Weld <subject> <object>'  value = 'WELD' )
        ( descr = 'Dunk <subject> <object>'  value = 'DUNK' )
        ( descr = 'Splash <subject> <object>'  value = 'SPLASH' )
         ).

     help_html =
      |<h2>Help</h2><p>| &
      |<h3>Navigation</h3><ul>| &&
      |<li>MAP        <em>Show map/ floor plan/ world</em>| &&
      |<li>N or NORTH <em>Walk to the room on the north side</em>| &&
      |<li>E or EAST  <em>Walk to the room on the east side</em>| &&
      `<li>S or SOUTH <em>Walk to the room on the south side</em>` &&
      `<li>W or WEST  <em>Walk to the room on the west side</em>` &&
      `<li>U or UP    <em>Go to the room upstairs</em>` &&
      `<li>D or DOWN  <em>Go to the room downstairs</em></ul><p>`.

      help_html = help_html &&
      |<h3>Interaction</h3>| &&
      |<ul><li>INV or INVENTORY <em>View everything you are carrying</em>| &&
      `<li>LOOK <em>Describe your environment</em>` &&
      `<li>LOOK object     <em>Have a closer look at the object in the room or in your inventory</em>` &&
      `<li>PICKUP object   (or TAKE) <em>Pickup an object in the current place</em>` &&
      `<li>DROP object     <em>Drop an object that you carry</em>` &&
      `<li>OPEN object     <em>Open something that is in the room</em></ul><p>`.

      help_html = help_html &&
      |<h3>Other</h3><ul>| &&
      `<li>ASK person            <em>Ask a person to tell you something</em>` &&
      `<li>CAST spell            <em>Cast a spell you have learned before</em>` &&
      `<li>WELD subject object   <em>Weld subject to the object if allowed</em>` &&
      `<li>DUNK subject object   <em>Dunk subject into object if allowed</em>` &&
      `<li>SPLASH subject object <em>Splash  subject into object</em></ul>`  &&
      `<pre>` &&
        '              _,._       ' && '<br>' &&
        '  .||,       /_ _\\\\     ' && '<br>' &&
        ' \.`'',/      |''L''| |     ' && '<br>' &&
        ' = ,. =      | -,| L     ' && '<br>' &&
        ' / || \    ,-''\"/,''`.    ' && '<br>' &&
        '   ||     ,''   `,,. `.  ' && '<br>' &&
        '   ,|____,'' , ,;'' \| |   ' && '<br>' &&
        '  (3|\    _/|/''   _| |   ' && '<br>' &&
        '   ||/,-''   | >-'' _,\\\\ ' && '<br>' &&
        '   ||''      ==\ ,-''  ,''  ' && '<br>' &&
        '   ||       |  V \ ,|    ' && '<br>' &&
        '   ||       |    |` |    ' && '<br>' &&
        '   ||       |    |   \   ' && '<br>' &&
        '   ||       |    \    \  ' && '<br>' &&
        '   ||       |     |    \ ' && '<br>' &&
        '   ||       |      \_,-'' ' && '<br>' &&
        '   ||       |___,,--")_\ ' && '<br>' &&
        '   ||         |_|   ccc/ ' && '<br>' &&
        '   ||        ccc/        ' && '<br>' &&
        '   ||                hjm ' && '<br>' &&
        `</pre>`.


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
      title          = 'The Wizard''s Adventure Game'
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
        title =  'abap2UI5 and AXAGE Adventure Game - The Wizard''s Guild Trials'
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
    grid->simple_form( title = 'Game Console - Quest for a Wizard''s Guild Aspirant' editable = abap_true )->content( 'form'
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

"    page->zz_plain( '<html:iframe src="https://github.com/nomssi/SAP-Developer-Code-Challenge/blob/main/img/livingroom.jpg" height="75%" width="98%"/>' ).

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
                )->toolbar_spacer(
        )->link(
             text = 'Credits'
             href  = 'http://landoflisp.com' ).
    client->set_next( VALUE #( xml_main = page->get_root( )->xml_get( ) ) ).
  ENDMETHOD.
ENDCLASS.
