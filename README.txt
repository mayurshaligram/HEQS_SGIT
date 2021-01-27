Flow:

      Page              Action                 Table                     Extension

Open Sales Order 
        |
        V
Type Information
        |
        |                                      Insert                     onBeforeInsert(change No to 0S)
        |                                      Modify                     onAfterModify(if exist Updata PO Updata ISO)
        V
     Release                                                              OnBeforeRelease(company check, 
        |                                                                        Ask Creation, Insert PO, 
        |                                                                        Ask Creation, Insert ISO) 
        |
        |
        V
      close
