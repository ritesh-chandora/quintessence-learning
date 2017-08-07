package btao.com.quintessencelearning;

import android.app.AlarmManager;
import android.app.Dialog;
import android.app.DialogFragment;
import android.app.PendingIntent;
import android.app.TimePickerDialog;
import android.content.Intent;
import android.icu.util.Calendar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.format.DateFormat;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TimePicker;
import android.widget.Toast;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import java.text.Format;
import java.text.SimpleDateFormat;

public class WelcomeScreen extends AppCompatActivity {
    public static String TAG = "WelcomeScreen";
    public static EditText time;
    public static Integer setHour = 0;
    public static Integer setMinute = 0;
    static FirebaseAuth auth = FirebaseAuth.getInstance();

    static FirebaseUser user = auth.getCurrentUser();

    static DatabaseReference mDatabase = FirebaseDatabase.getInstance().getReference();
    static DatabaseReference mUserRef = mDatabase.child("Users");

    static Long notification_time;

    static DatabaseReference mUser = mUserRef.child(user.getUid());

    private static PendingIntent pendingIntent;
    private static PendingIntent pending_now;
    static Calendar notif_calendar;




    public static class TimePickerFragment extends DialogFragment
            implements TimePickerDialog.OnTimeSetListener {

        @Override
        public Dialog onCreateDialog(Bundle savedInstanceState) {
            // Use the current time as the default values for the picker
            final Calendar c = Calendar.getInstance();
            int hour = c.get(Calendar.HOUR_OF_DAY);
            int minute = c.get(Calendar.MINUTE);

            // Create a new instance of TimePickerDialog and return it
            return new TimePickerDialog(getActivity(), this, hour, minute,
                    DateFormat.is24HourFormat(getActivity()));
        }

        public void onTimeSet(TimePicker t, int hourOfDay, int minute) {
            // Do something with the time chosen by the user
            String a="AM";
            if(hourOfDay>=12){
                hourOfDay=hourOfDay-12;
                a="PM";
            }
            String s;
            Format formatter;
            Calendar calendar = Calendar.getInstance();
            calendar.set(Calendar.HOUR_OF_DAY, t.getHour());
            calendar.set(Calendar.MINUTE, t.getMinute());
            calendar.clear(Calendar.SECOND); //reset seconds to zero
            notification_time = calendar.getTimeInMillis()/1000L;
            Log.d(TAG,Long.toString(notification_time));



            formatter = new SimpleDateFormat("hh:mm a");
            s = formatter.format(calendar.getTime()); // 08:00:00
            setHour = t.getHour();
            setMinute = t.getMinute();

            String timeString = s;
            WelcomeScreen.time.setText(timeString);

            notif_calendar = calendar;




            /*Calendar alarm_time = Calendar.getInstance();

            alarm_time.set(Calendar.MONTH, 6);
            alarm_time.set(Calendar.YEAR, 2013);
            alarm_time.set(Calendar.DAY_OF_MONTH, 13);

            alarm_time.set(Calendar.HOUR_OF_DAY, 20);
            alarm_time.set(Calendar.MINUTE, 48);
            alarm_time.set(Calendar.SECOND, 0);
            alarm_time.set(Calendar.AM_PM,Calendar.PM);*/




        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_welcome_screen);

    }

    public void pickTime(View view){
        time = (EditText) findViewById(R.id.time_edit);
        DialogFragment newFragment = new TimePickerFragment();
        newFragment.show(getFragmentManager(),"TimePicker");
    }

    public void finish(View view){
        if (notification_time!=null) {
            mUser.child("Time").setValue(notification_time);
        } else {
            Toast.makeText(getApplicationContext(),"You must pick a time",Toast.LENGTH_SHORT).show();
        }
        notif_calendar.add(Calendar.DATE,1);

        Intent myIntent = new Intent(getApplicationContext(), NotificationReceiver.class);
        pendingIntent = PendingIntent.getBroadcast(getApplicationContext(), 0, myIntent,0);
        pending_now = PendingIntent.getBroadcast(getApplicationContext(),1,myIntent,0);


        AlarmManager alarmManager = (AlarmManager) getApplicationContext().getSystemService(ALARM_SERVICE);

        alarmManager.set(AlarmManager.RTC_WAKEUP, System.currentTimeMillis() + (100), pending_now);
        alarmManager.setRepeating(AlarmManager.RTC_WAKEUP,notif_calendar.getTimeInMillis(),AlarmManager.INTERVAL_DAY,pendingIntent);

        //alarmManager.cancel(pendingIntent);

        Intent intent = new Intent(getApplicationContext(),MainActivity.class);
        intent.putExtra("setHour",setHour);
        intent.putExtra("setMinute",setMinute);
        intent.putExtra("sender","WelcomeScreen");
        startActivity(intent);
        finish();
    }
}


