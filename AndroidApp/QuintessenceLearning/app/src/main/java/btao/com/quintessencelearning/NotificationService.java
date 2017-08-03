package btao.com.quintessencelearning;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.graphics.Color;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.IBinder;
import android.util.Log;
import android.widget.Toast;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

/**
 * Created by Brian on 8/1/2017.
 */

public class NotificationService extends Service {

    FirebaseAuth auth = FirebaseAuth.getInstance();

    DatabaseReference mDatabaseRef = FirebaseDatabase.getInstance().getReference();
    DatabaseReference mQuestionRef = mDatabaseRef.child("Questions");
    DatabaseReference mUserRef = mDatabaseRef.child("Users");

    Long user_current_question;
    String user_email;
    Long user_join_date;
    String user_name;
    Boolean user_trial;
    String user_type;
    String user_uid;
    static Long user_time;
    static Long user_old_time;

    Long currentQuestion;

    static String TAG = "NotificationService";

    private NotificationManager mManager;

    @Override
    public IBinder onBind(Intent arg0)
    {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public void onCreate()
    {
        // TODO Auto-generated method stub
        super.onCreate();
    }

    @SuppressWarnings("static-access")
    @Override
    public int onStartCommand(Intent intent,int flags, int startId)
    {
        super.onStartCommand(intent,flags, startId);
        if (auth.getCurrentUser()!=null) {
            final DatabaseReference mUser = mUserRef.child(auth.getCurrentUser().getUid());

            mUser.addListenerForSingleValueEvent(new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot dataSnapshot) {
                    user_current_question = (Long) dataSnapshot.child("Current_Question").getValue();
                    user_email = (String) dataSnapshot.child("Email").getValue();
                    user_join_date = (Long) dataSnapshot.child("Join_Date").getValue();
                    user_name = (String) dataSnapshot.child("Name").getValue();
                    user_trial = (Boolean) dataSnapshot.child("Trial").getValue();
                    user_type = (String) dataSnapshot.child("Type").getValue();
                    user_uid = (String) dataSnapshot.child("UID").getValue();
                    user_time = (Long) dataSnapshot.child("Time").getValue();
                    user_current_question += 1;


                    if (dataSnapshot.child("Old_Time") == null) {
                        user_old_time = null;
                    } else {
                        user_old_time = (Long) dataSnapshot.child("Old_Time").getValue();
                    }

                    final ValueEventListener questionListener = new ValueEventListener() {
                        @Override
                        public void onDataChange(DataSnapshot dataSnapshot) {
                            // Get Post object and use the values to update the UI
                            for (DataSnapshot child : dataSnapshot.getChildren()) {
                                Log.d(TAG, "Inside class");
                                String text = (String) child.child("Text").getValue();
                                Long count = (Long) child.child("count").getValue();
                                if (count.equals(user_current_question)) {
                                    Log.d(TAG, text);
                                    mManager = (NotificationManager) getApplicationContext().getSystemService(getApplicationContext().NOTIFICATION_SERVICE);
                                    Intent intent1 = new Intent(getApplicationContext(), MainActivity.class);


                                    intent1.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_CLEAR_TOP);

                                    PendingIntent pendingNotificationIntent = PendingIntent.getActivity(getApplicationContext(), 0, intent1, PendingIntent.FLAG_UPDATE_CURRENT);
                                    Uri alarmSound = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
                                    Notification notification = new Notification.Builder(getApplicationContext())
                                            .setContentTitle("Today's Question")
                                            .setPriority(Notification.PRIORITY_HIGH)
                                            .setSound(alarmSound)
                                            .setVibrate(new long[]{500, 500})
                                            .setLights(Color.RED, 3000, 3000)
                                            .setContentText(text)
                                            .setSmallIcon(R.drawable.ic_notifications_black_24dp)
                                            .setWhen(System.currentTimeMillis())
                                            .setContentIntent(pendingNotificationIntent)
                                            .setAutoCancel(true)
                                            .build();
                                    //notification.flags |= Notification.FLAG_AUTO_CANCEL;
                                    //notification.setLatestEventInfo(this.getApplicationContext(), "AlarmManagerDemo", "This is a test message!", pendingNotificationIntent);

                                    mManager.notify(0, notification);
                                    mUser.child("Current_Question").setValue(user_current_question);


                                }
                            }
                        }

                        @Override
                        public void onCancelled(DatabaseError databaseError) {
                            // Getting Post failed, log a message
                            Toast.makeText(getApplicationContext(), databaseError.toString(), Toast.LENGTH_SHORT).show();
                            Log.w(TAG, "loadPost:onCancelled", databaseError.toException());
                            // ...
                        }
                    };

                    mQuestionRef.addListenerForSingleValueEvent(questionListener);


                }

                @Override
                public void onCancelled(DatabaseError databaseError) {
                    Log.d(TAG, "read failed");
                }
            });
        }

        return START_NOT_STICKY;


    }

    @Override
    public void onDestroy()
    {
        // TODO Auto-generated method stub
        super.onDestroy();
    }
}
