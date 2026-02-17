@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for booking'

@Metadata.allowExtensions: true
define view entity ZBC_C_BOOKING_M 
as projection on ZBC_I_BOOKING_M
{
    key TravelID,
   key BookingID,
    BookingDate,
    CustomerID,
    AirlineID,
    ConnectionID,
    FlightDate,
        @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
    /* Associations */
    Carrier,
    Connection,
    Customer,
    Travel: redirected to parent ZBC_C_TRAVEL_M
}
