@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for attachment'

@Metadata.allowExtensions: true
define view entity ZBC_C_DMO_ATTACH as projection on ZBC_I_DMO_ATTACH
{
    key TravelId,   
         AttachId,
     Comments,
    Filetype,
    Filename,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    Travel: redirected to parent ZBC_C_TRAVEL_M
}
