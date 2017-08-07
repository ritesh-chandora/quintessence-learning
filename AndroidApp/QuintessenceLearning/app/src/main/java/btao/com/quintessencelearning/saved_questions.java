package btao.com.quintessencelearning;

import android.provider.ContactsContract;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class saved_questions extends AppCompatActivity {

    FirebaseAuth auth;

    public static String TAG = "saved_questions";

    DatabaseReference mDatabaseRef = FirebaseDatabase.getInstance().getReference();
    DatabaseReference mQuestionsRef = mDatabaseRef.child("Questions");
    DatabaseReference mUsersRef = mDatabaseRef.child("Users");

    DatabaseReference mUser;
    List<String> saved_question_keys = new ArrayList<String>();
    ArrayList<Question> saved_questions = new ArrayList<Question>();
    ListView question_list;


    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        auth = FirebaseAuth.getInstance();
        setContentView(R.layout.activity_saved_questions);

        mUser = mUsersRef.child(auth.getCurrentUser().getUid());

        question_list = (ListView) findViewById(R.id.question_list);

        final ArrayAdapter<Question> listAdapter ;

        listAdapter = new QuestionsAdapter(this, saved_questions);

        final HashMap<String,ArrayList<Question>> tag_map = new HashMap<String,ArrayList<Question>>();




        mUser.child("Saved").orderByKey().addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                for (DataSnapshot q_key : dataSnapshot.getChildren()) {
                    saved_question_keys.add(q_key.getKey());
                }
                for (String key : saved_question_keys) {
                    mQuestionsRef.child(key).addListenerForSingleValueEvent(new ValueEventListener() {
                        @Override
                        public void onDataChange(DataSnapshot dataSnapshot) {
                            Question question = dataSnapshot.getValue(Question.class);
                            question.text = (String) dataSnapshot.child("Text").getValue();
                            question.created_by = (String) dataSnapshot.child("Created_By").getValue();
                            question.ctime = (Long) dataSnapshot.child("cTime").getValue();
                            question.count = (Long) dataSnapshot.child("count").getValue();
                            question.key = (String) dataSnapshot.child("Key").getValue();
                            List<String> tags = new ArrayList<>();
                            for (DataSnapshot tag:dataSnapshot.child("Tags").getChildren()){
                                String tag_id = tag.getValue().toString();
                                tags.add((String) tag.getValue());
                                if (tag_map.get(tag.getValue())==null){
                                    tag_map.put(tag_id,new ArrayList<Question>());
                                    tag_map.get(tag_id).add(question);
                                } else {
                                    tag_map.get(tag_id).add(question);
                                }
                            }
                            question.tags = tags;
                            saved_questions.add(question);
                            //listAdapter.add(question.getText());
                            question_list.setAdapter(listAdapter);

                            //view updates

                        }



                        @Override
                        public void onCancelled(DatabaseError databaseError) {
                            Log.d(TAG,"Firebase read cancelled");
                        }
                    });
                }



                Log.d(TAG,saved_questions.toString());
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {

            }
        });



    }
}
