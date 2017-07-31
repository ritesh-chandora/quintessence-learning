package btao.com.quintessencelearning;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomNavigationView;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;

import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.TextView;
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


public class MainActivity extends AppCompatActivity{

    private TextView mTextMessage;
    private FirebaseAuth auth;
    private DatabaseReference mDatabaseRef;
    private DatabaseReference mQuestionRef;
    private DatabaseReference mUserRef;
    private DatabaseReference mQuestion;
    private DatabaseReference mUser;
    Long currentQuestion;

    private QuestionsFragment qFrag;
    private AccountFragment aFrag;
    private Fragment fragment;
    private FragmentManager fragmentManager;

    private final String TAG = "MainActivity";

    FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();

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
                    String name = auth.getCurrentUser().getDisplayName();
                    String email = auth.getCurrentUser().getEmail();

                    aFrag = new AccountFragment();
                    fragment = aFrag;
                    transaction.replace(R.id.main_container, fragment).commit();
                    fragmentManager.executePendingTransactions();
                    aFrag.setName(name);
                    aFrag.setEmail(email);


                    fragment = new AccountFragment();
                    break;
                case R.id.navigation_feedback:
                    fragment = new FeedbackFragment();
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

        fragmentManager = getSupportFragmentManager();

        BottomNavigationView navigation = (BottomNavigationView) findViewById(R.id.navigation);
        navigation.setOnNavigationItemSelectedListener(mOnNavigationItemSelectedListener);
    }
    public void signOut(View view){
        auth.signOut();
        FirebaseUser user = auth.getCurrentUser();
        if (user == null) {
            startActivity(new Intent(getApplicationContext(), SignIn.class));
            finish();
        }
    }

    public void newQuestionFrag(String text){

        qFrag.setQuestion(text);
    }

    public void questionNav(){

        mTextMessage = (TextView) findViewById(R.id.text_message);
        if (auth.getCurrentUser() == null) {
            Intent intent = new Intent(this, SignIn.class);
            startActivity(intent);
            finish();
        }
        mDatabaseRef = FirebaseDatabase.getInstance().getReference();
        mQuestionRef = mDatabaseRef.child("Questions");
        mUserRef = mDatabaseRef.child("Users");

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
                    if (count==currentQuestion) {
                        Log.d(TAG, text);
                        newQuestionFrag(text);
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
                                        Toast.makeText(MainActivity.this, task.getException().getMessage(), Toast.LENGTH_SHORT).show();
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
                                        Toast.makeText(MainActivity.this, task.getException().getMessage(), Toast.LENGTH_SHORT).show();
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
}
