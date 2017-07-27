package btao.com.quintessencelearning;

import android.content.Intent;
import android.os.AsyncTask;
import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.JsonReader;
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
import com.google.gson.JsonIOException;
import com.google.gson.JsonObject;
import com.google.gson.JsonParseException;
import com.google.gson.JsonSyntaxException;
import com.koushikdutta.async.future.FutureCallback;
import com.koushikdutta.ion.Ion;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;

import javax.net.ssl.HttpsURLConnection;

public class SignIn extends AppCompatActivity {

    private EditText inputEmail, inputPassword;
    private FirebaseAuth auth;
    private ProgressBar progressBar;
    private Button btnSignup, btnLogin, btnReset;
    private static final String TAG = "SignIn";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);


        //auth = FirebaseAuth.getInstance();
        setContentView(R.layout.activity_sign_in);

    }
    public void signInAuth(View view){
        inputEmail = (EditText) findViewById(R.id.text_email);
        inputPassword = (EditText) findViewById(R.id.text_password);

        auth = FirebaseAuth.getInstance();
        String email = inputEmail.getText().toString();
        String password = inputPassword.getText().toString();
        try {
            auth.signInWithEmailAndPassword(email, password)
                    .addOnCompleteListener(SignIn.this, new OnCompleteListener<AuthResult>() {
                        @Override
                        public void onComplete(@NonNull Task<AuthResult> task) {
                            // If sign in fails, display a message to the user. If sign in succeeds
                            // the auth state listener will be notified and logic to handle the
                            // signed in user can be handled in the listener.

                            if (task.isSuccessful()) {
                                Log.d(TAG, "signin: success");
                                Toast.makeText(SignIn.this, "Logged In", Toast.LENGTH_SHORT).show();
                                Intent intent = new Intent(SignIn.this, MainActivity.class);
                                startActivity(intent);
                                finish();
                            } else {
                                Log.w(TAG, "signin failure", task.getException());
                                Toast.makeText(SignIn.this, task.getException().getMessage(), Toast.LENGTH_SHORT).show();
                            }
                        }
                    });
        } catch(IllegalArgumentException e) {
            e.printStackTrace();
            Toast.makeText(getApplicationContext(),"You cannot leave any fields blank",Toast.LENGTH_SHORT).show();
        }
    }

    public void signIn(View view){
        inputEmail = (EditText) findViewById(R.id.text_email);
        inputPassword = (EditText) findViewById(R.id.text_password);

        String email = inputEmail.getText().toString();
        String password = inputPassword.getText().toString();
        //JSONObject params = new JSONObject();
        JsonObject params = new JsonObject();

        try {
            params.addProperty("email", email);
            params.addProperty("password", password);
        } catch (JsonParseException e) {
            e.printStackTrace();
        }
        Ion.with(getApplicationContext())
                .load("http://192.168.1.252:3001/login")
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
                                Toast.makeText(SignIn.this,"Successfully Logged In", Toast.LENGTH_SHORT).show();
                                Intent intent = new Intent(SignIn.this,MainActivity.class);
                                startActivity(intent);
                                finish();
                            } else {
                                // Result is NOT "OK"
                                Toast.makeText(SignIn.this, json_result, Toast.LENGTH_LONG).show(); // This will show the user what went wrong with a toast
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

    public void signUp(View view){
        Intent intent = new Intent(this,SignUp.class);
        startActivity(intent);
    }
}
