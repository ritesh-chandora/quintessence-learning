package btao.com.quintessencelearning;

import android.content.Intent;
import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.Toast;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DatabaseReference;
import com.google.gson.JsonObject;
import com.google.gson.JsonParseException;
import com.koushikdutta.async.future.FutureCallback;
import com.koushikdutta.ion.Ion;

import org.json.JSONException;
import org.json.JSONObject;

public class SignUp extends AppCompatActivity {

    private EditText inputEmail, inputPassword, inputName;
    private FirebaseAuth auth;
    private ProgressBar progressBar;
    private Button btnSignup, btnLogin, btnReset;
    private final String TAG = "SignUp";
    private DatabaseReference mDatabase;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        auth = FirebaseAuth.getInstance();
        setContentView(R.layout.activity_sign_up);
    }
    public void Register(final View view){
        inputName = (EditText) findViewById(R.id.text_name);
        inputEmail = (EditText) findViewById(R.id.text_email);
        inputPassword = (EditText) findViewById(R.id.text_password);

        auth = FirebaseAuth.getInstance();
        String name = inputName.getText().toString();
        String email = inputEmail.getText().toString();
        String password = inputPassword.getText().toString();
        try {
            auth.createUserWithEmailAndPassword(email, password)
                    .addOnCompleteListener(SignUp.this, new OnCompleteListener<AuthResult>() {
                        @Override
                        public void onComplete(@NonNull Task<AuthResult> task) {
                            // If sign in fails, display a message to the user. If sign in succeeds
                            // the auth state listener will be notified and logic to handle the
                            // signed in user can be handled in the listener.
                            if (task.isSuccessful()) {
                                FirebaseUser user = auth.getCurrentUser();
                                String uid = user.getUid();
                                signUp(view, uid);
                                Log.d(TAG, "created user successfully");
                                Toast.makeText(SignUp.this, "Account Created", Toast.LENGTH_SHORT).show();

                                Intent intent = new Intent(getApplicationContext(), MainActivity.class);
                                startActivity(intent);
                                finish();
                            } else {
                                Log.w(TAG, "did not create user successfully", task.getException());
                                Toast.makeText(SignUp.this, task.getException().getMessage(), Toast.LENGTH_SHORT).show();
                            }
                        }
                    });
        } catch (IllegalArgumentException e){
            e.printStackTrace();
            Toast.makeText(getApplicationContext(),"You cannot leave any fields blank",Toast.LENGTH_SHORT).show();
        }
    }

    public void signUp(View view,String uid){
        inputName = (EditText) findViewById(R.id.text_name);
        inputEmail = (EditText) findViewById(R.id.text_email);
        inputPassword = (EditText) findViewById(R.id.text_password);

        String name = inputName.getText().toString();
        String email = inputEmail.getText().toString();
        String password = inputPassword.getText().toString();
        //JSONObject params = new JSONObject();
        JsonObject params = new JsonObject();

        try {
            params.addProperty("email", email);
            params.addProperty("password", password);
            params.addProperty("name",name);
            params.addProperty("uid",uid);
        } catch (JsonParseException e) {
            e.printStackTrace();
        }
        Ion.with(getApplicationContext())
                .load("http://172.25.201.218:3001/signup")
                .setHeader("Accept","application/json")
                .setHeader("Content-Type","application/json")
                .setJsonObjectBody(params)
                .asString()
                .setCallback(new FutureCallback<String>() {
                    @Override
                    public void onCompleted(Exception e, String result) {
                        try {
                            JSONObject json = new JSONObject(result);    // Converts the string "result" to a JSONObject
                            String json_result = json.getString("message"); // Get the string "result" inside the Json-object
                            if (json_result.equalsIgnoreCase("success")){ // Checks if the "result"-string is equals to "ok"
                                // Result is "OK"
                                Log.d(TAG,"successfully created account in db");
                                /*Toast.makeText(getApplicationContext(),"Successfully Created Account", Toast.LENGTH_SHORT).show();
                                Intent intent = new Intent(getApplicationContext(),MainActivity.class);
                                startActivity(intent);
                                finish();*/
                            } else {
                                // Result is NOT "OK"
                                Toast.makeText(getApplicationContext(), json_result, Toast.LENGTH_LONG).show(); // This will show the user what went wrong with a toast
                                //Intent to_main = new Intent(getApplicationContext(), SignIn.class); // New intent to MainActivity
                                //startActivity(to_main); // Starts MainActivity
                                //finish(); // Add this to prevent the user to go back to this activity when pressing the back button after we've opened MainActivity
                            }
                        } catch (JSONException err){
                            // This method will run if something goes wrong with the json, like a typo to the json-key or a broken JSON.
                            err.printStackTrace();
                        }
                    }
                });
    }
}
