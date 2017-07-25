public void signUp(View view){
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
                .load("http://192.168.1.252:3001/signup")
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
                                Toast.makeText(getApplicationContext(),"Successfully Created Account", Toast.LENGTH_SHORT).show();
                                Intent intent = new Intent(getApplicationContext(),MainActivity.class);
                                startActivity(intent);
                                finish();
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