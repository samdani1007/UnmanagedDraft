@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Travel'

@Metadata.allowExtensions: true
define root view entity ZBC_C_TRAVEL_M 
provider contract transactional_query
as projection on ZBC_I_TRAVEL_M as Travel
{
    key TravelID,
    AgencyID,
    CustomerID,
    BeginDate,
    EndDate,
        @Semantics.amount.currencyCode: 'CurrencyCode'
    BookingFee,
        @Semantics.amount.currencyCode: 'CurrencyCode'
    TotalPrice,
    CurrencyCode,
    Memo,
    Status,
    LastChangedAt,
    /* Associations */
    Agency ,
    Attach: redirected to composition child ZBC_C_DMO_ATTACH ,
    Booking : redirected to composition child ZBC_C_BOOKING_M,
    Currency,
    Customer,
    TravelStatus
   
}
