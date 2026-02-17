@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel view - CDS data model'

define root view entity ZBC_I_TRAVEL_M
  as select from /dmo/travel as Travel -- the travel table is the data source for this view

  composition [0..*] of ZBC_I_BOOKING_M as Booking
  composition [0..1] of ZBC_I_DMO_ATTACH as Attach

  association [0..1] to /DMO/I_Agency    as Agency   on $projection.AgencyID = Agency.AgencyID
  association [0..1] to /DMO/I_Customer  as Customer on $projection.CustomerID = Customer.CustomerID
  association [0..1] to I_Currency       as Currency on $projection.CurrencyCode = Currency.Currency
  association [1..1] to /DMO/I_Travel_Status_VH as TravelStatus on $projection.Status = TravelStatus.TravelStatus

{
  key Travel.travel_id     as TravelID,

      Travel.agency_id     as AgencyID,

      Travel.customer_id   as CustomerID,

      Travel.begin_date    as BeginDate,

      Travel.end_date      as EndDate,
    
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Travel.booking_fee   as BookingFee,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      Travel.total_price   as TotalPrice,

      Travel.currency_code as CurrencyCode,

      Travel.description   as Memo,

      Travel.status        as Status,

      Travel.lastchangedat as LastChangedAt,

      /* Associations */
      Booking,
      Agency,
      Customer,
      Currency,
      TravelStatus,
      Attach
}
