@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'attachment'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZBC_I_DMO_ATTACH as select from zbc_dmo_attach
association to parent ZBC_I_TRAVEL_M as Travel on $projection.TravelId = Travel.TravelID
{
    key travel_id as TravelId,
  
    @Semantics.largeObject:{ mimeType: 'Filetype',
    fileName: 'Filename',
    contentDispositionPreference: #INLINE 
     }
   attach_id as AttachId,
    comments as Comments,
    @Semantics.mimeType: true
    mimetype as Filetype,
    filename as Filename,
    @Semantics.user.createdBy: true
    local_created_by as LocalCreatedBy,
    @Semantics.systemDateTime.createdAt: true
    local_created_at as LocalCreatedAt,
    @Semantics.user.lastChangedBy: true
    local_last_changed_by as LocalLastChangedBy,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    local_last_changed_at as LocalLastChangedAt,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as LastChangedAt,
    
    /* association */
        Travel
}
