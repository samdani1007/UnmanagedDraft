@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking view'


define view entity ZBC_I_BOOKING_M
  as select from /dmo/booking as Booking 

  association        to parent ZBC_I_TRAVEL_M     as Travel     on  $projection.TravelID = Travel.TravelID
 

  association [1..1] to /DMO/I_Customer            as Customer   on  $projection.CustomerID = Customer.CustomerID
  association [1..1] to /DMO/I_Carrier             as Carrier    on  $projection.AirlineID = Carrier.AirlineID
  association [1..1] to /DMO/I_Connection          as Connection on  $projection.AirlineID    = Connection.AirlineID
                                                                  and $projection.ConnectionID = Connection.ConnectionID
                                                                  
{

  key Booking.travel_id     as TravelID,

  key Booking.booking_id    as BookingID,

      Booking.booking_date  as BookingDate,

      Booking.customer_id   as CustomerID,

      Booking.carrier_id    as AirlineID,

      Booking.connection_id as ConnectionID,

      Booking.flight_date   as FlightDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      Booking.flight_price  as FlightPrice,

      Booking.currency_code as CurrencyCode,

//     Travel.LastChangedAt as LastChangedAt, -- Take over ETag from parent

      /* Associations */
      Travel,
//      _BookSupplement,
      Customer,
      Carrier,
      Connection
}
