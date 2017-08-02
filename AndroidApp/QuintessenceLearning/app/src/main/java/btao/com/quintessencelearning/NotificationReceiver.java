package btao.com.quintessencelearning;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

/**
 * Created by Brian on 8/1/2017.
 */

public class NotificationReceiver extends BroadcastReceiver{
    @Override
    public void onReceive(Context context, Intent intent)
    {
        Intent service1 = new Intent(context, NotificationService.class);
        context.startService(service1);

    }
}
