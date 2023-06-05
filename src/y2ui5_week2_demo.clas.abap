CLASS y2ui5_week2_demo DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA username  TYPE string.
    DATA currentdate TYPE d.
    DATA check_initialized TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS y2ui5_week2_demo IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      username  = sy-uname.
      currentdate = sy-datum.
    ENDIF.

    CASE client->get( )-event.
      WHEN 'BUTTON_POST'.
        select single land From t005x where land EQ 'DE' INTO @Data(land).
        client->popup_message_toast( |App executed on { currentdate COUNTRY = land } by { username }| ).
    ENDCASE.

    client->set_next( VALUE #( xml_main = Z2UI5_CL_XML_VIEW=>factory(
        )->shell(
        )->page( title = 'abap2UI5 - Week2 Challenge'
            )->simple_form( title = 'Input Form Demo Week 2' editable = abap_true
                )->content( ns = `form`
                    )->title( 'Sample User / Date input form'
                    )->label( 'User'
                    )->input( value = client->_bind( username )
                    )->label( 'Date'
                    )->input(
                        value   = client->_bind( currentdate )
                    )->button(
                        text  = 'post'
                        press = client->_event( 'BUTTON_POST' )
         )->get_root( )->xml_get( ) ) ).

  ENDMETHOD.
ENDCLASS.

