package btao.com.quintessencelearning;

import android.app.AlarmManager;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.app.PendingIntent;
import android.app.TimePickerDialog;
import android.content.DialogInterface;
import android.content.Intent;
import java.text.SimpleDateFormat;
import java.util.Calendar;

import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomNavigationView;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;

import android.support.v7.app.AppCompatActivity;
import android.text.format.DateFormat;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.TimePicker;
import android.widget.Toast;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.google.gson.JsonObject;
import com.google.gson.JsonParseException;
import com.koushikdutta.async.future.FutureCallback;
import com.koushikdutta.ion.Ion;


import java.util.ArrayList;
import java.util.List;

import btao.com.quintessencelearning.util.IabHelper;
import btao.com.quintessencelearning.util.IabResult;
import btao.com.quintessencelearning.util.Inventory;
import btao.com.quintessencelearning.util.Purchase;


public class MainActivity extends AppCompatActivity{


    public static FirebaseAuth auth;
    public static DatabaseReference mDatabaseRef = FirebaseDatabase.getInstance().getReference();
    public static DatabaseReference mQuestionRef = mDatabaseRef.child("Questions");
    public static DatabaseReference mUserRef = mDatabaseRef.child("Users");

    public static DatabaseReference mUser;
    Long currentQuestion;

    private QuestionsFragment qFrag;
    private AccountFragment aFrag;
    private Fragment fragment;
    private FragmentManager fragmentManager;

    private static final String TAG = "MainActivity";

    static Integer notification_hour = 0;
    static Integer notification_minute = 0;

    Long user_current_question;
    String user_email;
    Long user_join_date;
    String user_name;
    Boolean user_trial;
    String user_type;
    String user_uid;
    static Long user_time;
    static Long user_old_time;

    static String current_question_text;
    static String current_question_key;
    static List<String> tags = new ArrayList<String>();

    FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();

    private static PendingIntent pendingIntent;

    static final String SKU_1 = "sku_name_goes_here";
    private String public_key = "public_key_goes_here";
    private IabHelper mIABHelper;
    private MainActivity activity;
    private static final int RC_REQUEST = 07746;
    private static boolean mSubscribed = false;

    private BottomNavigationView.OnNavigationItemSelectedListener mOnNavigationItemSelectedListener
            = new BottomNavigationView.OnNavigationItemSelectedListener() {

        @Override
        public boolean onNavigationItemSelected(@NonNull MenuItem item) {
            final FragmentTransaction transaction = fragmentManager.beginTransaction();
            switch (item.getItemId()) {
                case R.id.navigation_questions:

                    qFrag = new QuestionsFragment();
                    fragment = qFrag;

                    transaction.replace(R.id.main_container, fragment).commit();
                    fragmentManager.executePendingTransactions();

                    questionNav();

                    break;
                case R.id.navigation_account:
                    aFrag = new AccountFragment();
                    fragment = aFrag;
                    transaction.replace(R.id.main_container, fragment).commit();
                    fragmentManager.executePendingTransactions();

                    aFrag.setName(user_name);
                    aFrag.setEmail(user_email);
                    String account_type;
                    if (user_type == "admin") {
                        account_type = getString(R.string.type_admin);
                    } else if (user_type == "user" && !user_trial) {
                        account_type = getString(R.string.type_subscribed);
                    } else {
                        account_type = getString(R.string.type_trial);
                    }

                    aFrag.setAccountType(account_type);
                    Calendar joinDate = Calendar.getInstance();
                    SimpleDateFormat formatter = new SimpleDateFormat("EEE, MMM d yyyy");
                    joinDate.setTimeInMillis(user_join_date*1000L);
                    String formatted = formatter.format(joinDate.getTimeInMillis());
                    aFrag.setJoinDate(formatted);

                    Calendar notificationTime = Calendar.getInstance();
                    notificationTime.set(Calendar.HOUR_OF_DAY,notification_hour);
                    notificationTime.set(Calendar.MINUTE,notification_minute);

                    SimpleDateFormat formatterTime = new SimpleDateFormat("hh:mm a");
                    String formattedTime = formatterTime.format(notificationTime.getTimeInMillis());
                    aFrag.setNotificationTime(formattedTime);

                    fragment = new AccountFragment();

                    break;
                case R.id.navigation_feedback:
                    fragment = new FeedbackFragment();
                    transaction.replace(R.id.main_container, fragment).commit();
                    fragmentManager.executePendingTransactions();
                    break;
            }
            return true;
        }

    };



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        auth = FirebaseAuth.getInstance();

        setContentView(R.layout.activity_main);


        if (auth.getCurrentUser() == null) {
            Intent intent = new Intent(getApplicationContext(), SignIn.class);
            startActivity(intent);
            finish();
        }
        if (auth.getCurrentUser()!=null) {

            //TODO turn this on when google play is setup
            //createPurchaseHelper();

            final String userUID = user.getUid();
            mUser = mUserRef.child(userUID);




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
                    Calendar time = Calendar.getInstance();
                    time.setTimeInMillis(user_time*1000L);
                    notification_hour=time.get(Calendar.HOUR_OF_DAY);
                    notification_minute=time.get(Calendar.MINUTE);

                    if(dataSnapshot.child("Old_Time")==null){
                        user_old_time = null;
                    } else {
                        user_old_time = (Long) dataSnapshot.child("Old_Time").getValue();
                    }

                    Intent myIntent = new Intent(getApplicationContext(), NotificationReceiver.class);
                    pendingIntent = PendingIntent.getBroadcast(getApplicationContext(), 0, myIntent,0);

                    boolean alarmUp = (PendingIntent.getBroadcast(getApplicationContext(), 0, myIntent, PendingIntent.FLAG_NO_CREATE) != null);

                    if (alarmUp)
                    {
                        Log.d(TAG, "Alarm is already active");
                    } else {
                        Log.d(TAG,"Alarm is not active, please set it");
                        Calendar new_time = Calendar.getInstance();
                        new_time.set(Calendar.HOUR_OF_DAY,notification_hour);
                        new_time.set(Calendar.MINUTE,notification_minute);
                        new_time.clear(Calendar.SECOND);

                        Calendar current_time = Calendar.getInstance();
                        if (current_time.getTimeInMillis()>new_time.getTimeInMillis()) {
                            new_time.add(Calendar.DATE, 1);
                        }

                        AlarmManager alarmManager = (AlarmManager) getApplicationContext().getSystemService(ALARM_SERVICE);
                        alarmManager.setRepeating(AlarmManager.RTC_WAKEUP,new_time.getTimeInMillis(),AlarmManager.INTERVAL_DAY,pendingIntent);

                    }
                }

                @Override
                public void onCancelled(DatabaseError databaseError) {
                    Log.d(TAG, "read failed");
                }
            });
            fragmentManager = getSupportFragmentManager();
            final FragmentTransaction transaction = fragmentManager.beginTransaction();
            qFrag = new QuestionsFragment();
            fragment = qFrag;

            transaction.replace(R.id.main_container, fragment).commit();
            fragmentManager.executePendingTransactions();


            questionNav();

        }



        BottomNavigationView navigation = (BottomNavigationView) findViewById(R.id.navigation);
        navigation.setOnNavigationItemSelectedListener(mOnNavigationItemSelectedListener);


    }
    public void signOut(View view){
        auth.signOut();

        Intent myIntent = new Intent(getApplicationContext(), NotificationReceiver.class);
        pendingIntent = PendingIntent.getBroadcast(getApplicationContext(), 0, myIntent,0);

        AlarmManager alarmManager = (AlarmManager) getApplicationContext().getSystemService(ALARM_SERVICE);

        alarmManager.cancel(pendingIntent);
        pendingIntent.cancel();

        FirebaseUser user = auth.getCurrentUser();
        if (user == null) {
            startActivity(new Intent(getApplicationContext(), SignIn.class));
            finish();
        }
    }

    public void questionNav(){

        if (auth.getCurrentUser() == null) {
            Intent intent = new Intent(this, SignIn.class);
            startActivity(intent);
            finish();
        }


        final String userUID = user.getUid();
        mUser = mUserRef.child(userUID);


        final ValueEventListener questionListener = new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                // Get Post object and use the values to update the UI
                for (DataSnapshot child : dataSnapshot.getChildren()) {
                    Log.d(TAG, "Inside class");
                    String text = (String) child.child("Text").getValue();
                    Long count = (Long) child.child("count").getValue();
                    String key = (String) child.child("Key").getValue();
                    if (currentQuestion.equals(new Long(-1))) {
                        currentQuestion+=1L;
                    }

                    if (count.equals(currentQuestion)) {
                        Log.d(TAG, text);
                        current_question_text = text;
                        current_question_key = key;
                        for (DataSnapshot tag : child.child("Tags").getChildren()){
                            tags.add((String) tag.getValue());
                        }

                        qFrag.setQuestion(text);
                        break;
                    }
                }
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                // Getting Post failed, log a message
                Toast.makeText(getApplicationContext(),databaseError.toString(),Toast.LENGTH_SHORT).show();
                Log.w(TAG, "loadPost:onCancelled", databaseError.toException());
                // ...
            }
        };

        mUser.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                currentQuestion = (Long) dataSnapshot.child("Current_Question").getValue();
                mQuestionRef.addListenerForSingleValueEvent(questionListener);
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                Log.d(TAG,"Couldn't get user ref");
            }
        });

    }

    public void changeEmail(View view){
        AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
        builder.setTitle(R.string.change_email);
        LayoutInflater inflater = getLayoutInflater();
        builder.setView(inflater.inflate(R.layout.email_dialog,null));
        builder.setPositiveButton(R.string.change, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id) {
                // User clicked OK button
                Log.d(TAG,"Positive click");
                Dialog dialogD = (Dialog) dialog;
                EditText et = (EditText) dialogD.findViewById(R.id.text_change_email);
                String val = et.getText().toString();
                try {
                    user.updateEmail(val)
                            .addOnCompleteListener(new OnCompleteListener<Void>() {
                                @Override
                                public void onComplete(@NonNull Task<Void> task) {
                                    if (task.isSuccessful()) {
                                        Log.d(TAG, "User email address updated.");
                                        Toast.makeText(MainActivity.this, "Email Updated", Toast.LENGTH_SHORT).show();
                                    } else {
                                        Log.w(TAG, "Did not update", task.getException());
                                        Toast.makeText(MainActivity.this, task.getException().getMessage(), Toast.LENGTH_LONG).show();
                                    }
                                }
                            });
                } catch(IllegalArgumentException e) {
                    e.printStackTrace();
                    Toast.makeText(getApplicationContext(),"You cannot leave any fields blank",Toast.LENGTH_SHORT).show();
                }
            }
        });
        builder.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id) {
                // User cancelled the dialog
                Log.d(TAG,"Negative click");
            }
        });
        AlertDialog dialog = builder.create();
        dialog.show();
    }

    public void changePassword(View view){

        AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
        builder.setTitle(R.string.change_password);
        LayoutInflater inflater = getLayoutInflater();
        builder.setView(inflater.inflate(R.layout.password_dialog,null));
        builder.setPositiveButton(R.string.change, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id) {
                // User clicked OK button
                Log.d(TAG,"Positive click");
                Dialog dialogD = (Dialog) dialog;
                EditText et = (EditText) dialogD.findViewById(R.id.text_change_password);
                String val = et.getText().toString();
                //((InputMethodManager)getSystemService(getApplicationContext().INPUT_METHOD_SERVICE))
                //        .showSoftInput(et, InputMethodManager.SHOW_IMPLICIT);
                try {
                    user.updatePassword(val)
                            .addOnCompleteListener(new OnCompleteListener<Void>() {
                                @Override
                                public void onComplete(@NonNull Task<Void> task) {
                                    if (task.isSuccessful()) {
                                        Log.d(TAG, "User Password updated.");
                                        Toast.makeText(MainActivity.this, "Password Updated", Toast.LENGTH_SHORT).show();
                                    } else {
                                        Log.w(TAG, "Did not update", task.getException());
                                        Toast.makeText(MainActivity.this, task.getException().getMessage(), Toast.LENGTH_LONG).show();
                                    }
                                }
                            });
                } catch(IllegalArgumentException e) {
                    e.printStackTrace();
                    Toast.makeText(getApplicationContext(),"You cannot leave any fields blank",Toast.LENGTH_SHORT).show();
                }
            }
        });
        builder.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id) {
                // User cancelled the dialog
                Log.d(TAG,"Negative click");
            }
        });
        AlertDialog dialog = builder.create();
        dialog.show();
    }

    public void aboutUs(View view){
        AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
        builder.setTitle(R.string.about_us);
        LayoutInflater inflater = getLayoutInflater();
        builder.setView(inflater.inflate(R.layout.about_us_dialog,null));
        AlertDialog dialog = builder.create();
        dialog.show();
    }

    public void submitQuestion(View view){

        AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
        builder.setTitle(R.string.submit_question);
        LayoutInflater inflater = getLayoutInflater();
        builder.setView(inflater.inflate(R.layout.submit_question_dialog,null));
        builder.setPositiveButton(R.string.submit, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id) {
                // User clicked OK button
                Log.d(TAG,"Positive click");
                Dialog dialogD = (Dialog) dialog;
                EditText question_edit = (EditText) dialogD.findViewById(R.id.text_question);
                EditText question_tags = (EditText) dialogD.findViewById(R.id.text_tags);
                String question;
                String tags;
                question = question_edit.getText().toString();
                tags = question_tags.getText().toString();
                //Toast.makeText(getApplicationContext(),"You cannot leave fields blank",Toast.LENGTH_SHORT).show();

                JsonObject params = new JsonObject();
                String email = auth.getCurrentUser().getEmail();
                String subject = "New question from " + email;

                String content = "<p>"+user_name+","+email+" submitted a question:</p>";
                content+="<p>Question:"+question+"</p>";
                content+="<p>Tags:"+tags+"</p>";
                Log.d(TAG,content);

                try {
                    params.addProperty("subject", subject);
                    params.addProperty("content", content);
                } catch (JsonParseException e) {
                    e.printStackTrace();
                }
                Ion.with(getApplicationContext())
                        .load(R.string.ip+"/email")
                        .setHeader("Accept","application/json")
                        .setHeader("Content-Type","application/json")
                        .setJsonObjectBody(params)
                        .asString()
                        .setCallback(new FutureCallback<String>() {
                            @Override
                            public void onCompleted(Exception e, String result) {
                                Toast.makeText(getApplicationContext(),"Question Submitted",Toast.LENGTH_SHORT).show();
                            }
                        });
            }
        });
        builder.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id) {
                // User cancelled the dialog
                Log.d(TAG,"Negative click");
            }
        });
        builder.show();
    }

    public void submitFeedback(View view){

        AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
        builder.setTitle(R.string.submit_feedback);
        LayoutInflater inflater = getLayoutInflater();
        builder.setView(inflater.inflate(R.layout.submit_feedback_dialog,null));
        builder.setPositiveButton(R.string.submit, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id) {
                // User clicked OK button
                Log.d(TAG,"Positive click");
                Dialog dialogD = (Dialog) dialog;
                EditText mYour_name = (EditText) dialogD.findViewById(R.id.text_your_name);
                EditText mYour_email = (EditText) dialogD.findViewById(R.id.text_your_email);
                EditText mYour_subject = (EditText) dialogD.findViewById(R.id.text_your_subject);
                EditText mYour_content = (EditText) dialogD.findViewById(R.id.text_your_content);

                String your_name = mYour_name.getText().toString();
                String your_email = mYour_email.getText().toString();
                String your_subject = mYour_subject.getText().toString();
                String your_content = mYour_content.getText().toString();

                JsonObject params = new JsonObject();
                String subject = "Feedback from:  " + your_name+ " ("+your_email+") "+your_subject ;

                String content = "<p>"+your_name+","+your_email+" submitted feedback:</p>";
                content+="<p>Feedback:" + your_content+"</p>";
                Log.d(TAG,content);

                try {
                    params.addProperty("subject", subject);
                    params.addProperty("content", content);
                } catch (JsonParseException e) {
                    e.printStackTrace();
                }
                Ion.with(getApplicationContext())
                        .load("http://192.168.1.252:3000/email")
                        .setHeader("Accept","application/json")
                        .setHeader("Content-Type","application/json")
                        .setJsonObjectBody(params)
                        .asString()
                        .setCallback(new FutureCallback<String>() {
                            @Override
                            public void onCompleted(Exception e, String result) {
                                Toast.makeText(getApplicationContext(),"Feedback Submitted",Toast.LENGTH_SHORT).show();
                            }
                        });
            }
        });
        builder.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id) {
                // User cancelled the dialog
                Log.d(TAG,"Negative click");
            }
        });
        builder.show();
    }

    public void fAQ(View view){
        AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
        builder.setTitle(R.string.FAQ_title);
        LayoutInflater inflater = getLayoutInflater();
        builder.setView(inflater.inflate(R.layout.faq_dialog,null));
        builder.show();

    }

    public void eBook(View view){
        AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
        builder.setTitle(R.string.ebook_title);
        LayoutInflater inflater = getLayoutInflater();
        builder.setView(inflater.inflate(R.layout.ebook_dialog,null));
        builder.show();

    }

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
            mUser = mUserRef.child(auth.getCurrentUser().getUid());
            Calendar new_time = Calendar.getInstance();
            if (Build.VERSION.SDK_INT < 23){
                new_time.set(Calendar.HOUR_OF_DAY,t.getCurrentHour());
                new_time.set(Calendar.MINUTE,t.getCurrentMinute());
            } else {
                new_time.set(Calendar.HOUR_OF_DAY, t.getHour());
                new_time.set(Calendar.MINUTE, t.getMinute());
            }
            new_time.add(Calendar.DATE,1);
            new_time.clear(Calendar.SECOND); //reset seconds to zero
            Long new_time_sec = new_time.getTimeInMillis()/1000;
            mUser.child("Time").setValue(new_time_sec);

            Calendar old_time = Calendar.getInstance();
            old_time.set(Calendar.HOUR_OF_DAY, notification_hour);
            old_time.set(Calendar.MINUTE, notification_minute);
            old_time.clear(Calendar.SECOND); //reset seconds to zero

            Calendar current_time = Calendar.getInstance();


            Intent myIntent = new Intent(getActivity(), NotificationReceiver.class);
            pendingIntent = PendingIntent.getBroadcast(getActivity(), 0, myIntent,0);
            PendingIntent old_pending = PendingIntent.getBroadcast(getActivity(),1,myIntent,0);

            AlarmManager alarmManager = (AlarmManager) getActivity().getSystemService(ALARM_SERVICE);

            alarmManager.cancel(pendingIntent);
            if (current_time.getTimeInMillis()<old_time.getTimeInMillis()) {
                alarmManager.set(AlarmManager.RTC_WAKEUP, old_time.getTimeInMillis(), old_pending);
            }
            alarmManager.setRepeating(AlarmManager.RTC_WAKEUP,new_time.getTimeInMillis(),AlarmManager.INTERVAL_DAY,pendingIntent);

            notification_hour=new_time.get(Calendar.HOUR_OF_DAY);
            notification_minute=new_time.get(Calendar.MINUTE);

            Toast.makeText(getActivity(),R.string.time_updated,Toast.LENGTH_SHORT).show();




        }
    }

    public void setTime(View view){
        Integer current_hour=notification_hour;
        Integer current_minute = notification_minute;
        Calendar old_time = Calendar.getInstance();
        old_time.set(Calendar.HOUR_OF_DAY, current_hour);
        old_time.set(Calendar.MINUTE, current_minute);
        old_time.clear(Calendar.SECOND); //reset seconds to zero
        Long old_time_sec = old_time.getTimeInMillis()/1000;



        mUser = mUserRef.child(auth.getCurrentUser().getUid());

        mUser.child("Old_Time").setValue(old_time_sec);

        DialogFragment newFragment = new TimePickerFragment();
        newFragment.show(getFragmentManager(),"TimePicker");

    }

    public void viewSavedQuestions(View view){
        Intent intent = new Intent(getApplicationContext(),saved_questions.class);
        startActivity(intent);

    }

    private void createPurchaseHelper(){
        mIABHelper = new IabHelper(this, public_key);
        mIABHelper.enableDebugLogging(true);
        mIABHelper.startSetup(new IabHelper.OnIabSetupFinishedListener() {
            public void onIabSetupFinished(IabResult result) {
                if (!result.isSuccess()){
                    Log.d(TAG, "Error problem setting up inapp billing" + result);
                    return;
                }
                if (mIABHelper == null) return;
                try {
                    mIABHelper.queryInventoryAsync(mGotInventoryListener);
                } catch (IabHelper.IabAsyncInProgressException e){
                    Log.d(TAG,"Inventory Async error: " + e);
                    e.printStackTrace();
                }

            }
        });
    }

    IabHelper.QueryInventoryFinishedListener mGotInventoryListener = new IabHelper.QueryInventoryFinishedListener() {
        public void onQueryInventoryFinished(IabResult result, Inventory inventory) {
            if (mIABHelper == null) return;

            if (result.isFailure()) {
                Log.d(TAG,"Failed to query inventory" + result);
                return;
            }
            Log.d(TAG,"Query inventory was successful");

            Purchase subPurchase = inventory.getPurchase(SKU_1);

            if (subPurchase != null && verifyDeveloperPayload(subPurchase)) {
                mSubscribed=true;
                //TODO update UI
            }
        }
    };

    boolean verifyDeveloperPayload(Purchase p) {
        String payload = p.getDeveloperPayload();
        //TODO add verification
        return true;
    }

    public void purchaseSubscription(View view) {
        //TODO add developer payload paramter
        try {
            mIABHelper.launchSubscriptionPurchaseFlow(this, SKU_1, RC_REQUEST, mPurchaseFinishedListener, "");
        } catch (IabHelper.IabAsyncInProgressException e) {
            Log.d(TAG,"Purchase Async error" + e);
            e.printStackTrace();
        }
    }

    IabHelper.OnIabPurchaseFinishedListener mPurchaseFinishedListener = new IabHelper.OnIabPurchaseFinishedListener() {
        public void onIabPurchaseFinished(IabResult result, Purchase purchase) {
            if (mIABHelper == null) return;

            if (result.isFailure()){
                Log.d(TAG,"Purchase error:" + result);
                return;
            }
            Log.d(TAG,"Purchase successful");

            if(purchase != null && purchase.getSku().equals(SKU_1) && verifyDeveloperPayload(purchase)){
                Toast.makeText(getApplicationContext(),R.string.thank_you,Toast.LENGTH_SHORT).show();
                mSubscribed = true;
                //TODO update UI
            }
        }
    };

    @Override
    protected void onActivityResult(int requestCode,int resultCode,Intent data) {
        if (mIABHelper == null) return;

        if (mIABHelper.handleActivityResult(requestCode,resultCode,data)){
            Log.d(TAG,"onActivityResult handled by mhelper");
        } else {
            super.onActivityResult(requestCode,resultCode,data);
        }
    }
}