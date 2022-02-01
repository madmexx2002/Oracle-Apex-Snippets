/**
 * Need a table called SA_SUBSCRIPTION with two fields (APP_USER, EVENT)
 * Also add two css classes
 * .activated {
 *   color: red;
 * }
 * .inactive {
 *   color: black;
 * } 
 */

declare
  type T_EVENTS_TAB is
    table of SA_SUBSCRIPTION.EVENT%type;
  L_EVENTS    T_EVENTS_TAB;
  L_EVENT     SA_SUBSCRIPTION.EVENT%type;
  K_ACTIVATED constant varchar2(16) := 'activated';
  K_INACTIVE  constant varchar2(16) := 'inactive';
begin
  APEX_JSON.OPEN_OBJECT;

  -- Process Button click or Page Load
  if APEX_APPLICATION.G_X01 is not null then
    -- Button was clicked
    begin
      select EVENT 
        into L_EVENT
        from SA_SUBSCRIPTION
       where APP_USER = :APP_USER
         and EVENT = APEX_APPLICATION.G_X01;
      
      -- Record was found. Delete it for unsubscription
      delete SA_SUBSCRIPTION
       where APP_USER = :APP_USER
         and EVENT = APEX_APPLICATION.G_X01;

      APEX_JSON.WRITE(APEX_APPLICATION.G_X01, K_INACTIVE);
    
    exception
      -- If no record was found set subscription for event
      when NO_DATA_FOUND then
        insert into SA_SUBSCRIPTION (
          APP_USER
        , EVENT
        ) values (
          :APP_USER
        , APEX_APPLICATION.G_X01
        );
        APEX_JSON.WRITE(APEX_APPLICATION.G_X01, K_ACTIVATED);
    end;
  
  end if;
  
  --Check status of buttons
  if APEX_APPLICATION.G_F01.COUNT > 0 then

    -- Load user settings for events from array into new array
    select EVENT
      bulk collect
      into L_EVENTS
      from SA_SUBSCRIPTION
     where APP_USER = :APP_USER;

    -- Loop input array and check against new array
    for I in 1..APEX_APPLICATION.G_F01.COUNT loop
    
      -- Active because element of new array
      if APEX_APPLICATION.G_F01(I) member of L_EVENTS then
        APEX_JSON.WRITE(APEX_APPLICATION.G_F01(I), K_ACTIVATED);
      
      -- Inactive because not an element of array
      else
        APEX_JSON.WRITE(APEX_APPLICATION.G_F01(I), K_INACTIVE);
      end if;
      
    end loop;

  end if;

  APEX_JSON.CLOSE_OBJECT;
end;