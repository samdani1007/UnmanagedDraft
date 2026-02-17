CLASS ltcl_handler DEFINITION DEFERRED FOR TESTING.

CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler FRIENDS ltcl_handler.
  PRIVATE SECTION .

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Travel.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Travel.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Travel.

    METHODS read FOR READ
      IMPORTING keys FOR READ Travel RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Travel.

    METHODS rba_Booking FOR READ
      IMPORTING keys_rba FOR READ Travel\Booking FULL result_requested RESULT result LINK association_links.

    METHODS cba_Booking FOR MODIFY
      IMPORTING entities_cba FOR CREATE Travel\Booking.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS is_create_granted
      IMPORTING country_code          TYPE land1 OPTIONAL
      RETURNING VALUE(create_granted) TYPE abap_bool.
    METHODS is_update_granted
      IMPORTING country_code          TYPE land1 OPTIONAL
      RETURNING VALUE(update_granted) TYPE abap_bool.
    METHODS is_delete_granted
      IMPORTING country_code          TYPE land1 OPTIONAL
      RETURNING VALUE(delete_granted) TYPE abap_bool.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.





  ENDMETHOD.

  METHOD get_global_authorizations.

   IF requested_authorizations-%create EQ if_abap_behv=>mk-on.
      IF is_create_granted( ) = abap_true.
        result-%create = if_abap_behv=>auth-allowed.
      ELSE.
        result-%create = if_abap_behv=>auth-unauthorized.
        APPEND VALUE #( %msg    = NEW /dmo/cm_flight_messages(
                                       textid   = /dmo/cm_flight_messages=>not_authorized
                                       severity = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on ) TO reported-travel.

      ENDIF.
    ENDIF.

    "Edit is treated like update
    IF requested_authorizations-%update                =  if_abap_behv=>mk-on. "OR
*       requested_authorizations-          =  if_abap_behv=>mk-on
.

      IF  is_update_granted( ) = abap_true.
        result-%update                =  if_abap_behv=>auth-allowed.
*        result-%action-Edit           =  if_abap_behv=>auth-allowed.

      ELSE.
        result-%update                =  if_abap_behv=>auth-unauthorized.
*        result-%action-Edit           =  if_abap_behv=>auth-unauthorized.

        APPEND VALUE #( %msg    = NEW /dmo/cm_flight_messages(
                                       textid   = /dmo/cm_flight_messages=>not_authorized
                                       severity = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on )
          TO reported-travel.

      ENDIF.
    ENDIF.


    IF requested_authorizations-%delete =  if_abap_behv=>mk-on.
      IF is_delete_granted( ) = abap_true.
        result-%delete = if_abap_behv=>auth-allowed.
      ELSE.
        result-%delete = if_abap_behv=>auth-unauthorized.
        APPEND VALUE #( %msg    = NEW /dmo/cm_flight_messages(
                                       textid   = /dmo/cm_flight_messages=>not_authorized
                                       severity = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDIF.




  ENDMETHOD.

  METHOD create.

  DATA: messages   TYPE /dmo/t_message,
          travel_in  TYPE /dmo/travel,
          travel_out TYPE /dmo/travel.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel_create>).

      travel_in = CORRESPONDING #( <travel_create> MAPPING FROM ENTITY USING CONTROL ).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_CREATE'
        EXPORTING
          is_travel         = CORRESPONDING /dmo/s_travel_in( travel_in )
          iv_numbering_mode = /dmo/if_flight_legacy=>numbering_mode-late
        IMPORTING
          es_travel         = travel_out
          et_messages       = messages.


  if messages is inITIAL.
  insert vALUE #( %cid = <travel_create>-%cid travelid = travel_out-travel_id ) into table mapped-travel.
  else.

  AppEND vALUE #(  travelid = travel_in-travel_id ) to failed-travel.

 APPEND VALUE #(  travelid =  travel_in-travel_id
                   %msg  = new_message(  id = messages[ 1 ]-msgid
                                      number = messages[ 1 ]-msgno
                                      v1 = messages[ 1 ]-msgv1
                                      v2 = messages[ 2 ]-msgv2
                                        v3 = messages[ 2 ]-msgv3
                                          v4 = messages[ 2 ]-msgv4
                                          severity = CONV #( messages[ 1 ]-msgty ) ) ) to reported-travel.

  enDIF.

  enDLOOP.

  ENDMETHOD.

  METHOD update.

    DATA: messages TYPE /dmo/t_message,
          travel   TYPE /dmo/travel,
          travelx  TYPE /dmo/s_travel_inx.
    data:  begin of travelx_s,
           travel_id type /dmo/travel_id,
            _intx TYPE zbc_s_travel_indx, "refers to x structure (> BAPIs)
           end OF travelx_s.


    LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel_update>).

      travel = CORRESPONDING #( <travel_update> MAPPING FROM ENTITY ).

      travelx_s-travel_id = <travel_update>-TravelID.
      travelx_s-_intx     = CORRESPONDING #( <travel_update> MAPPING FROM ENTITY ).

       travelx-travel_id  = travelx_s-travel_id.
      travelx-_intx =    corrESPONDING #( travelx_s-_intx  ).
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = CORRESPONDING /dmo/s_travel_in( travel )
          is_travelx  = travelx
        IMPORTING
          et_messages = messages.
  if messages is inITIAL.
*  appEND vALUE #(  travelid = travel-travel_id ) to mapped-travel.
  else.

  AppEND vALUE #(  travelid = travel-travel_id ) to failed-travel.

 APPEND VALUE #(  travelid =  travel-travel_id
                   %msg  = new_message(  id = messages[ 1 ]-msgid
                                      number = messages[ 1 ]-msgno
                                      v1 = messages[ 1 ]-msgv1
                                      v2 = messages[ 2 ]-msgv2
                                        v3 = messages[ 2 ]-msgv3
                                          v4 = messages[ 2 ]-msgv4
                                          severity = CONV #( messages[ 1 ]-msgty ) ) ) to reported-travel.

  enDIF.

  eNDLOOP.



  ENDMETHOD.

  METHOD delete.
  DATA: messages TYPE /dmo/t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<travel_delete>).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_DELETE'
        EXPORTING
          iv_travel_id = <travel_delete>-travelid
        IMPORTING
          et_messages  = messages.

       if messages is inITIAL.
  appEND vALUE #(  travelid = <travel_delete>-travelid ) to mapped-travel.
  else.

  AppEND vALUE #(  travelid = <travel_delete>-travelid ) to failed-travel.

 APPEND VALUE #(  travelid = <travel_delete>-travelid
                   %msg  = new_message(  id = messages[ 1 ]-msgid
                                      number = messages[ 1 ]-msgno
                                      v1 = messages[ 1 ]-msgv1
                                      v2 = messages[ 2 ]-msgv2
                                        v3 = messages[ 2 ]-msgv3
                                          v4 = messages[ 2 ]-msgv4
                                          severity = CONV #( messages[ 1 ]-msgty ) ) ) to reported-travel.

  enDIF.


endLOOP.
  ENDMETHOD.

  METHOD read.


 "Keys will contain draft flag fields in unmanaged draft scenarios
  DATA lt_active_keys TYPE STANDARD TABLE OF /dmo/travel-travel_id.
  DATA lt_draft_keys  TYPE STANDARD TABLE OF zbc_dmo_travel_d-travelid.

  LOOP AT keys ASSIGNING FIELD-SYMBOL(<k>).
    "Field name depends on generated types, commonly %is_draft / %is_active_entity
    IF <k>-%is_draft = abap_true.
      APPEND <k>-TravelID TO lt_draft_keys.
    ELSE.
      APPEND <k>-TravelID TO lt_active_keys.
    ENDIF.
  ENDLOOP.

  IF lt_active_keys IS NOT INITIAL.
    SELECT FROM /dmo/travel
      FIELDS travel_id, agency_id, customer_id, begin_date, end_date,
             booking_fee, total_price, currency_code, description, status, lastchangedat
      FOR ALL ENTRIES IN @lt_active_keys
      WHERE travel_id = @lt_active_keys-table_line
      INTO TABLE @DATA(lt_active).
  ENDIF.

  IF lt_draft_keys IS NOT INITIAL.
    SELECT FROM zbc_dmo_travel_d
      FIELDS travelid, agencyid, customerid, begindate, enddate,
             bookingfee, totalprice, currencycode, memo, status, lastchangedat,
             draftuuid, hasactiveentity
      FOR ALL ENTRIES IN @lt_draft_keys
      WHERE travelid = @lt_draft_keys-table_line
      INTO TABLE @DATA(lt_draft).
  ENDIF.

if lt_active is not INITIAL.
  "Map to result (CORRESPONDING works if field names align with CDS)
  result = VALUE #(
    FOR active IN lt_active ( CORRESPONDING #( active MAPPING
                                                       AgencyID = agency_id
                                                       TravelID = travel_id
                                                       BeginDate = begin_date
                                                       EndDate = end_date
                                                       BookingFee = booking_fee
                                                       CustomerID = customer_id
                                                       CurrencyCode = currency_code
                                                       Status = status
                                                       TotalPrice = total_price
                                                       LastChangedAt = lastchangedat
                                                       Memo = description   ) )
  ).
ENDIF.

IF lt_draft IS NOT INITIAL.
  result = VALUE #( BASE result
    FOR draft IN lt_draft ( CORRESPONDING #( draft ) )
  ).

ENDIF.


  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Booking.
  ENDMETHOD.

  METHOD cba_Booking.

   DATA: messages        TYPE /dmo/t_message,
          lt_booking_old     TYPE /dmo/t_booking,
          booking         TYPE /dmo/booking,
          last_booking_id TYPE /dmo/booking_id VALUE '0'.

    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<travel>).

      DATA(travelid) = <travel>-travelid.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = travelid
        IMPORTING
          et_booking   = lt_booking_old
          et_messages  = messages.

       IF messages IS INITIAL.

       IF lt_booking_old IS NOT INITIAL.

         last_booking_id = lt_booking_old[ lines( lt_booking_old ) ]-booking_id.
       endif.

       LOOP AT <travel>-%target ASSIGNING FIELD-SYMBOL(<booking_create>).

          booking = CORRESPONDING #( <booking_create> MAPPING FROM ENTITY USING CONTROL ) .

          last_booking_id += 1.
          booking-booking_id = last_booking_id.

          CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
            EXPORTING
              is_travel   = VALUE /dmo/s_travel_in( travel_id = travelid )
              is_travelx  = VALUE /dmo/s_travel_inx( travel_id = travelid )
              it_booking  = VALUE /dmo/t_booking_in( ( CORRESPONDING #( booking ) ) )
              it_bookingx = VALUE /dmo/t_booking_inx(
                (
                  booking_id  = booking-booking_id
                  action_code = /dmo/if_flight_legacy=>action_code-create
                )
              )
            IMPORTING
              et_messages = messages.

         IF messages IS INITIAL.

            INSERT
              VALUE #(
                %cid = <booking_create>-%cid
                travelid = travelid
                bookingid = <booking_create>-bookingid
              )
              INTO TABLE mapped-booking.


         else.

         INSERT VALUE #( %cid = <booking_create>-%cid travelid = travelid ) INTO TABLE failed-booking.

            LOOP AT messages INTO DATA(message) WHERE msgty = 'E' OR msgty = 'A'.

             INSERT
                VALUE #(
                  %cid     = <booking_create>-%cid
                  travelid = <booking_create>-TravelID
                  %msg     = new_message(
                    id       = message-msgid
                    number   = message-msgno
                    severity = if_abap_behv_message=>severity-error
                    v1       = message-msgv1
                    v2       = message-msgv2
                    v3       = message-msgv3
                    v4       = message-msgv4
                  )
                )
                INTO TABLE reported-booking.

            ENDLOOP.

        endIF.


        eNDLOOP.

     else.

     "fill failed return structure for the framework
        APPEND VALUE #( travelid = travelid ) TO failed-travel.
        "fill reported structure to be displayed on the UI
        APPEND VALUE #( travelid = travelid
                        %msg = new_message( id = messages[ 1 ]-msgid
                                            number = messages[ 1 ]-msgno
                                            v1 = messages[ 1 ]-msgv1
                                            v2 = messages[ 1 ]-msgv2
                                            v3 = messages[ 1 ]-msgv3
                                            v4 = messages[ 1 ]-msgv4
                                            severity = CONV #( messages[ 1 ]-msgty ) )
       ) TO reported-travel.


       endif.


    endlOOP.



  ENDMETHOD.

  METHOD is_create_granted.

   "For validation
    IF country_code IS SUPPLIED.
      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
        ID '/DMO/CNTRY' FIELD country_code
        ID 'ACTVT'      FIELD '01'.
      create_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).

      "Simulation for full authorization
      "(not to be used in productive code)
      create_granted = abap_true.

      " simulation of auth check for demo,
      " auth granted for country_code US, else not
*      CASE country_code.
*        WHEN 'US'.
*          create_granted = abap_true.
*        WHEN OTHERS.
*          create_granted = abap_false.
*      ENDCASE.

      "For global auth
    ELSE.
      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
        ID '/DMO/CNTRY' DUMMY
        ID 'ACTVT'      FIELD '01'.
      create_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).

      "Simulation for full authorization
      "(not to be used in productive code)
      create_granted = abap_true.
    ENDIF.


  ENDMETHOD.

  METHOD is_delete_granted.

     "For instance auth
    IF country_code IS SUPPLIED.
      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
        ID '/DMO/CNTRY' FIELD country_code
        ID 'ACTVT'      FIELD '06'.
      delete_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).

      "Simulation for full authorization
      "(not to be used in productive code)
      delete_granted = abap_true.

*      " simulation of auth check for demo,
*      " auth granted for country_code US, else not
*      CASE country_code.
*        WHEN 'US'.
*          delete_granted = abap_true.
*        WHEN OTHERS.
*          delete_granted = abap_false.
*      ENDCASE.

      "For global auth
    ELSE.
      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
        ID '/DMO/CNTRY' DUMMY
        ID 'ACTVT'      FIELD '06'.
      delete_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).

      "Simulation for full authorization
      "(not to be used in productive code)
      delete_granted = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD is_update_granted.

    "For instance auth
    IF country_code IS SUPPLIED.
      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
        ID '/DMO/CNTRY' FIELD country_code
        ID 'ACTVT'      FIELD '02'.
      update_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).

      "Simulation for full authorization
      "(not to be used in productive code)
      update_granted = abap_true.

      " simulation of auth check for demo,
      " auth granted for country_code US, else not
*      CASE country_code.
*        WHEN 'US'.
*          update_granted = abap_true.
*        WHEN OTHERS.
*          update_granted = abap_false.
*      ENDCASE.

      "For global auth
    ELSE.
      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
        ID '/DMO/CNTRY' DUMMY
        ID 'ACTVT'      FIELD '02'.
      update_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).

      "Simulation for full authorization
      "(not to be used in productive code)
      update_granted = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD get_instance_features.

  READ ENTITIES OF zbc_i_travel_u IN LOCAL MODE
      ENTITY Travel
        FIELDS ( Status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(travels)
      FAILED failed.

  result = VALUE #( FOR ls_travel IN travels
                          ( %tky                   = ls_travel-%tky


                            %assoc-Booking        = COND #( WHEN ls_travel-Status = 'N'
                                                            THEN if_abap_behv=>fc-o-disabled
                                                            ELSE if_abap_behv=>fc-o-enabled )
                          ) ).


  ENDMETHOD.

ENDCLASS.

CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Booking.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Booking.

    METHODS read FOR READ
      IMPORTING keys FOR READ Booking RESULT result.

    METHODS rba_Travel FOR READ
      IMPORTING keys_rba FOR READ Booking\Travel FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD update.

   DATA: messages TYPE /dmo/t_message,
          booking  TYPE /dmo/booking,
          bookingx TYPE /dmo/s_booking_inx.

      data:  begin of bookingx_s,
           booking_id type /dmo/booking_id,
            _intx TYPE zbc_s_booking_indx, "refers to x structure (> BAPIs)
           end OF bookingx_s.


    LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking>).

      booking = CORRESPONDING #( <booking> MAPPING FROM ENTITY ).


      bookingx_s-booking_id = <booking>-BookingID.
      bookingx_s-_intx     = CORRESPONDING #( <booking> MAPPING FROM ENTITY ).


      bookingx-_intx       = CORRESPONDING #( bookingx_s-_intx  ).
      bookingx-booking_id  =  bookingx_s-booking_id.
      bookingx-action_code = /dmo/if_flight_legacy=>action_code-update.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = VALUE /dmo/s_travel_in( travel_id = <booking>-travelid )
          is_travelx  = VALUE /dmo/s_travel_inx( travel_id = <booking>-travelid )
          it_booking  = VALUE /dmo/t_booking_in( ( CORRESPONDING #( booking ) ) )
          it_bookingx = VALUE /dmo/t_booking_inx( ( bookingx ) )
        IMPORTING
          et_messages = messages.


      IF messages IS INITIAL.

*        APPEND VALUE #( travelid = <booking>-travelid
*                       bookingid = booking-booking_id ) TO mapped-booking.

      ELSE.

        "fill failed return structure for the framework
        APPEND VALUE #( travelid = <booking>-travelid
                        bookingid = booking-booking_id ) TO failed-booking.
        "fill reported structure to be displayed on the UI

        LOOP AT messages INTO DATA(message).
          "fill reported structure to be displayed on the UI
          APPEND VALUE #( travelid = <booking>-travelid
                          bookingid = booking-booking_id
                  %msg = new_message( id = message-msgid
                                                number = message-msgno
                                                v1 = message-msgv1
                                                v2 = message-msgv2
                                                v3 = message-msgv3
                                                v4 = message-msgv4
                                                severity = CONV #( message-msgty ) )
         ) TO reported-booking.
        ENDLOOP.

      ENDIF.


    endLOOP.

  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Travel.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZBC_I_TRAVEL_U DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

      METHODS adjust_numbers REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZBC_I_TRAVEL_U IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.

  CALL FUNCTION '/DMO/FLIGHT_TRAVEL_SAVE'.

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

  METHOD adjust_numbers.

   DATA: travel_mapping       TYPE /dmo/if_flight_legacy=>tt_ln_travel_mapping,
          booking_mapping      TYPE /dmo/if_flight_legacy=>tt_ln_booking_mapping.


    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_ADJ_NUMBERS'
      IMPORTING
        et_travel_mapping       = travel_mapping
        et_booking_mapping      = booking_mapping.


    mapped-travel            = VALUE #( FOR travel IN travel_mapping ( %tmp                = VALUE #( TravelID = travel-preliminary-travel_id )
                                                                       TravelID            = travel-final-travel_id ) ).

    mapped-booking           = VALUE #( FOR booking IN booking_mapping ( %tmp                = VALUE #( TravelID  = booking-preliminary-travel_id
                                                                                                        BookingID = booking-preliminary-booking_id )
                                                                         TravelID            = booking-final-travel_id
                                                                         BookingID           = booking-final-booking_id ) ).



  ENDMETHOD.

ENDCLASS.
