declare
  type T_EVENTS_TAB is
    table of SA_SUBSCRIPTION.EVENT%type;
  L_EVENTS    T_EVENTS_TAB;
  L_EVENT     SA_SUBSCRIPTION.EVENT%type;
  K_ACTIVE constant boolean := true;
  K_INACTIVE  constant boolean := false;
begin

  -- Open JSON Object
  APEX_JSON.OPEN_OBJECT;

  -- New Object for Button Settings. Adapt to your needs
  APEX_JSON.OPEN_OBJECT('settings');
    APEX_JSON.write('active_text', 'Unsubscribe from this event');
    APEX_JSON.write('inactive_text', 'Subscribe to this event');
    APEX_JSON.write('active_color', '#f50537');
    APEX_JSON.write('inactive_color', '#000000');
  APEX_JSON.CLOSE_OBJECT;

  -- New Object for the events
  APEX_JSON.OPEN_OBJECT('events');

  -- Process Button click
  if APEX_APPLICATION.G_X01 is not null then
    -- Button was clicked
      delete SA_SUBSCRIPTION
       where APP_USER = :APP_USER
         and EVENT = APEX_APPLICATION.G_X01;

      if sql%ROWCOUNT = 0 then
        -- No reocrd was found. Insert new record
        insert into SA_SUBSCRIPTION (APP_USER, EVENT) 
          values (:APP_USER, APEX_APPLICATION.G_X01);
        APEX_JSON.write(APEX_APPLICATION.G_X01, K_ACTIVE);
      else
        -- Record was deleted 
        APEX_JSON.write(APEX_APPLICATION.G_X01, K_INACTIVE);
      end if;
  
  end if;
  
  -- Process for all Buttons on Page Load
  if APEX_APPLICATION.G_F01.count > 0 then

    -- Load user settings for events into new array. Doesn't take care of events from APEX_APPLICATION.G_F01 :(
    select EVENT
      bulk collect
      into L_EVENTS
      from SA_SUBSCRIPTION
     where APP_USER = :APP_USER;

    -- Loop input array and check against new array
    for i in 1..APEX_APPLICATION.G_F01.count loop
    
      -- Active because element of new array
      if APEX_APPLICATION.G_F01(i) member of L_EVENTS then
        APEX_JSON.write(APEX_APPLICATION.G_F01(i), K_ACTIVE);
      
      -- Inactive because not an element of array
      else
        APEX_JSON.write(APEX_APPLICATION.G_F01(i), K_INACTIVE);
      end if;
      
    end loop;

  end if;

  APEX_JSON.CLOSE_ALL;
  
exception 
  when others then
    APEX_JSON.INITIALIZE_OUTPUT;
    APEX_JSON.OPEN_OBJECT;
    if APEX_APPLICATION.g_debug then
      APEX_JSON.WRITE('error', 'Error while processing subscription.<br><i>'   || sqlerrm || '</i>');
    else
      APEX_JSON.WRITE('error', 'Error while processing subscription');
    end if;
    APEX_JSON.CLOSE_OBJECT;    
end;