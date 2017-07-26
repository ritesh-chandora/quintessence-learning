var tags = ['Learning','Critical Thinking','Analysis'];

function create(){
  //creates two refs for the database, and then the questions collection
  var root = firebase.database().ref(); 
  var qref = root.child('Questions');
  var tagRef = root.child('Tags');
  //these two variables are the question text and the tag (replace with other input method)
  var question = document.getElementById('question').value;
  var qtag = document.getElementById('tag').value;
  //checks if current user is signed in
  if(firebase.auth().currentUser){
    //pushes object into the questions collection
    var key = root.child('Questions').push().key;
    var user = firebase.auth().currentUser.uid
    var ctime = firebase.database.ServerValue.TIMESTAMP;
    qref.child(key).set({Text:question,Key:key,Created_By:user,cTime:ctime});
    var len = tags.length;
    for (i=0;i<len;i++){
      qref.child(key).child('Tags').push(tags[i]);
      tagRef.child(tags[i]).push(key);
    }
    console.log('pushed successfully');
  }
  else {
    console.log('not logged in');
  }

}


function read(ascending=false,startAt= 	,endAt=-1){
  //root and questions refs
  var root = firebase.database().ref();
  var qref = root.child('Questions');
  //instantiates question list to be returned
  var qlist = [];
  if (endAt===-1){
  	endAt = String(firebase.database.ServerValue.TIMESTAMP);
  }
  //checks if user is logged in
  if(firebase.auth().currentUser){
    //orders the questions in time order descending and then then listens for values
    qref.orderByChild('cTime').startAt(startAt).endAt(endAt).on('value',function(snap) {
      //iterates through each value in the snap
      snap.forEach(function(snap)
      {
        //grabs the text, tags, created by, key
        var taglist=[];
        var key= snap.key;
        var text =snap.child('Text').val();
        var tags = snap.child('Tags');
        var created = snap.child('Created_By').val();
        var ctime = snap.child('cTime');
        tags.forEach(function(tag)
        {
          taglist.push(tag.val());
        });
        //makes a list out of those elements
        var sublist = new Array(text,taglist,key,created,ctime);

        console.log(sublist);
        //pushes into the question list
        if (ascending===true) {
          qlist.push(sublist);
        } else {
          qlist.unshift(sublist);
        }
      });
      console.log(qlist);

      //this display function sends values to the front end, isnt really necessary for expresss
      display(snap.val());
      return qlist;
    });
  }
  else {
    console.log('user logged out');
  }
  //returns qlist
}

function remove(){
  //establishes refs
  var root = firebase.database().ref();
  var qref = root.child('Questions');
  var tagRef = root.child('Tags');
  //questionKey is the variable that holds the key for the question you are trying to delete
  var questionKey= document.getElementById('tag').value;
  //userKey is the current users unique ID
  var userKey = firebase.auth().currentUser.uid;
  //checks if the question you are trying to delete is created by the current user
  qref.child(questionKey).child('Created_By').once('value',function(snap){
    var question_create = snap.val();

    if (userKey===question_create) {
	    //removes the question
	    qref.child(questionKey).remove(function(err){
	      if (err) {
	        console.log('Question Deletion Error',err);
	      } else {
	        console.log('Question Deleted');
	      }
	    });
    tagRef.once('value',function (snap){
	    	snap.forEach(function(child){
	    		console.log(child.val());
		    	child.ref.once('value',function(snap){
		    		snap.forEach(function(child){
		    			if (child.val() === questionKey) {
		    				child.ref.remove()
		    			}
		    		});
		    	});
		    });
		});
    	console.log('Question was not created by current user');
  	}
  
  });

}
function update(){
  //establishes refs
  var root = firebase.database().ref();
  var qref = root.child('Questions');
  //question key is the unique question key you are updating
  var questionKey= document.getElementById('tag').value;
  //userkey is the curret logged in users unique ID
  var userKey = firebase.auth().currentUser.uid;
  //newText is the text you are updating the question with
  var newText = document.getElementById('question').value;
  //newTags is the list of tags you are updating the question with
  var newTags = ['new tag 1','new tag 2'];
  //checks if the question you're trying to update was created by the current user
  qref.child(questionKey).child('Created_By').once('value',function(snap){
    var question_create = snap.val();
    if (userKey===question_create) {
    //updates the question text
    qref.child(questionKey).update({Text:newText});
    //removes old tags
    qref.child(questionKey).child('Tags').remove(function(err){
      if (err){
        console.log('Tag deletion error',err);
      } else {
        console.log('Tags deleted');
      }
    })
    //pushes new tags
    var len = newTags.length;
    for (i=0;i<len;i++){
      qref.child(questionKey).child('Tags').push(newTags[i]);
    }
  } else {
    console.log('Question was not created by current user');
  }
  });
}

function save(){
  var root = firebase.database().ref();
  var userRef = root.child('Users');
  var questionRef = root.child('Questions');

  var questionKey = document.getElementById('tag').value;
  var userKey=firebase.auth().currentUser.uid;
  userRef.child(userKey).child('Saved').push(questionKey);
  console.log('Question Saved');
}
function selectQuestion(){
  
}
function display(data){
  document.getElementById('db_questions').textContent=JSON.stringify(data, null, '\n');
}
function toggleSignIn() {
  if (firebase.auth().currentUser) {
    // [START signout]
    var qref = firebase.database().ref().child('Questions').off();
    firebase.auth().signOut();
    // [END signout]
  } else {
    var email = document.getElementById('email').value;
    var password = document.getElementById('password').value;
    if (email.length < 4) {
      alert('Please enter an email address.');
      return;
    }
    if (password.length < 4) {
      alert('Please enter a password.');
      return;
    }
    // Sign in with email and pass.
    // [START authwithemail]
    firebase.auth().signInWithEmailAndPassword(email, password).catch(function(error) {
      // Handle Errors here.
      var errorCode = error.code;
      var errorMessage = error.message;
      // [START_EXCLUDE]
      if (errorCode === 'auth/wrong-password') {
        alert('Wrong password.');
      } else {
        alert(errorMessage);
      }
      console.log(error);
      document.getElementById('quickstart-sign-in').disabled = false;
      // [END_EXCLUDE]
    });
    // [END authwithemail]
  }
  document.getElementById('quickstart-sign-in').disabled = true;
}

/**
 * Handles the sign up button press.
 */
function handleSignUp() {
  var email = document.getElementById('email').value;
  var password = document.getElementById('password').value;
  if (email.length < 4) {
    alert('Please enter an email address.');
    return;
  }
  if (password.length < 4) {
    alert('Please enter a password.');
    return;
  }
  var root = firebase.database().ref();
  var userRef = root.child('Users');
  var currentQ = 0;
  var joinDate=firebase.database.ServerValue.TIMESTAMP;
  var name = document.getElementById('name').value;
  var trial = true;
  var type = "user";
  //var userKey = userRef.push().key;
  
  // Sign in with email and pass.
  // [START createwithemail]
  firebase.auth().createUserWithEmailAndPassword(email, password).then(function(){
    var uid = firebase.auth().currentUser.uid;
    userRef.child(uid).set(
    {Current_Question:currentQ,Email:email,
    Join_Date:joinDate,
    //Key:userKey,
    Name:name,
    Trial:trial,
    Type:type,
    UID:uid
    })
  }).catch(function(error) {
    // Handle Errors here.
    var errorCode = error.code;
    var errorMessage = error.message;
    // [START_EXCLUDE]
    if (errorCode == 'auth/weak-password') {
      alert('The password is too weak.');
    } else {
      alert(errorMessage);
    }
    console.log(error);
    // [END_EXCLUDE]
  });
  // [END createwithemail]
}

function returnQuestionInfo(qKey){
  var root = firebase.database().ref();
  var questionRef = root.child('Questions');

  var question = [];
  var query = questionRef.child(qKey).once('value', function(snap){
    var createdBy = snap.child('Created_By').val();
    var key = snap.child('Key').val();
    var text = snap.child('Text').val();
    var cTime = snap.child('cTime').val();
    var tags = [];
    snap.child('Tags').forEach(function(child){
      tags.push(child.val());
    })
    question.push(new Array(createdBy,key,text,cTime,tags));
  })
  return question;
}

function saveQuestion(qKey){
	var root = firebase.database().ref();
	var userRef = root.child('Users');
	var userKey = firebase.auth().currentUser.uid;
	userRef.child(userKey).child('Saved').push(qKey);
}

function selectTags(){
  var root = firebase.database().ref();
  var tagRef = root.child('Tags');
  var questions=[];
  var tag = document.getElementById('tag').value;
  var query = tagRef.child(tag).orderByKey().once('value',function(snap){
    snap.forEach(function(child){
      qKeys.push(returnQuestionInfo(child.val()));
    });
  });
  return questions; 

  //options: limitToFirst()/limitToLast(),
  //Orders: orderByChild(),orderByKey(),orderByValue()
}
function selectTagName(){
  var root = firebase.database().ref();
  var tagRef = root.child('Tags');
  var questions=[];
  tagRef.once('value',function(snap){
    snap.forEach(function(child){
      console.log(child.key);
      questions.push(child.key);
    })
  }).then(function(){
    console.log(questions);
  }); 

  //options: limitToFirst()/limitToLast(),
  //Orders: orderByChild(),orderByKey(),orderByValue()
}

function selectTagsAnd(tag1,tag2)
{
  var and = [];
  var tags1=selectTags(tag1);
  var tags2=selectTags(tag2);
  and.push(tags1);
  and.push(tags2);

  and.sort(function(a,b){

  })
}

/**
 * Sends an email verification to the user.
 */
function sendEmailVerification() {
  // [START sendemailverification]
  firebase.auth().currentUser.sendEmailVerification().then(function() {
    // Email Verification sent!
    // [START_EXCLUDE]
    alert('Email Verification Sent!');
    // [END_EXCLUDE]
  });
  // [END sendemailverification]
}

function sendPasswordReset() {
  var email = document.getElementById('email').value;
  // [START sendpasswordemail]
  firebase.auth().sendPasswordResetEmail(email).then(function() {
    // Password Reset Email Sent!
    // [START_EXCLUDE]
    alert('Password Reset Email Sent!');
    // [END_EXCLUDE]
  }).catch(function(error) {
    // Handle Errors here.
    var errorCode = error.code;
    var errorMessage = error.message;
    // [START_EXCLUDE]
    if (errorCode == 'auth/invalid-email') {
      alert(errorMessage);
    } else if (errorCode == 'auth/user-not-found') {
      alert(errorMessage);
    }
    console.log(error);
    // [END_EXCLUDE]
  });
  // [END sendpasswordemail];
}

/**
 * initApp handles setting up UI event listeners and registering Firebase auth listeners:
 *  - firebase.auth().onAuthStateChanged: This listener is called when the user is signed in or
 *    out, and that is where we update the UI.
 */
function initApp() {
  // Listening for auth state changes.
  // [START authstatelistener]
  firebase.auth().onAuthStateChanged(function(user) {
    // [START_EXCLUDE silent]
    document.getElementById('quickstart-verify-email').disabled = true;
    // [END_EXCLUDE]
    if (user) {
      // User is signed in.
      var displayName = user.displayName;
      var email = user.email;
      var emailVerified = user.emailVerified;
      var photoURL = user.photoURL;
      var isAnonymous = user.isAnonymous;
      var uid = user.uid;
      var providerData = user.providerData;
      // [START_EXCLUDE]
      document.getElementById('quickstart-sign-in-status').textContent = 'Signed in';
      document.getElementById('quickstart-sign-in').textContent = 'Sign out';
      document.getElementById('quickstart-account-details').textContent = JSON.stringify(user, null, '  ');
      if (!emailVerified) {
        document.getElementById('quickstart-verify-email').disabled = false;
      }
      // [END_EXCLUDE]
    } else {
      // User is signed out.
      // [START_EXCLUDE]
      document.getElementById('quickstart-sign-in-status').textContent = 'Signed out';
      document.getElementById('quickstart-sign-in').textContent = 'Sign in';
      document.getElementById('quickstart-account-details').textContent = 'null';
      // [END_EXCLUDE]
    }
    // [START_EXCLUDE silent]
    document.getElementById('quickstart-sign-in').disabled = false;
    // [END_EXCLUDE]
  });
  // [END authstatelistener]

  document.getElementById('quickstart-sign-in').addEventListener('click', toggleSignIn, false);
  document.getElementById('quickstart-sign-up').addEventListener('click', handleSignUp, false);
  document.getElementById('quickstart-verify-email').addEventListener('click', sendEmailVerification, false);
  document.getElementById('quickstart-password-reset').addEventListener('click', sendPasswordReset, false);
  document.getElementById('submit').addEventListener('click',create,false);
  document.getElementById('read').addEventListener('click',read,false);
  document.getElementById('delete').addEventListener('click',remove,false);
  document.getElementById('update').addEventListener('click',update,false);
  document.getElementById('save').addEventListener('click',save,false);
  document.getElementById('selectTag').addEventListener('click',selectTagName,false);
  var header=document.getElementById('header')
  var dbref = firebase.database().ref().child('header')
  dbref.on('value',snap => header.innerText=snap.val());
}

window.onload = function() {
	console.log('initiating app');
	initApp();
}