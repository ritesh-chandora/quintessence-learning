package btao.com.quintessencelearning;


import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.text.Layout;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.Toast;

import java.util.concurrent.TimeUnit;


/**
 * A simple {@link Fragment} subclass.
 * Use the {@link QuestionsFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class QuestionsFragment extends Fragment {
    private final String TAG = "MainActivity";


    TextView text_tags;



    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    // TODO: Rename and change types of parameters
    private String mParam1;
    private String mParam2;


    public QuestionsFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment QuestionsFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static QuestionsFragment newInstance(String param1, String param2) {
        QuestionsFragment fragment = new QuestionsFragment();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            mParam1 = getArguments().getString(ARG_PARAM1);
            mParam2 = getArguments().getString(ARG_PARAM2);
        }

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        //questionNav();
        final View view = inflater.inflate(R.layout.fragment_questions, container, false);

        TextView text_question1 = (TextView) view.findViewById(R.id.text_message1);
        text_question1.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                LayoutInflater inflater = getActivity().getLayoutInflater();
                View dialogView = inflater.inflate(R.layout.question_properties_dialog,null);
                AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
                builder.setTitle(R.string.question_properties);
                builder.setView(dialogView);
                builder.setPositiveButton(R.string.save_question, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        Log.d(TAG,"Positive click");
                        Log.d(TAG,"saved");

                        MainActivity.mUser = MainActivity.mUserRef.child(MainActivity.auth.getCurrentUser().getUid());
                        MainActivity.mUser.child("Saved").child(MainActivity.current_question_key.get(0)).setValue(true);

                        Toast.makeText(getActivity().getApplicationContext(), "Question has been saved", Toast.LENGTH_SHORT).show();

                    }
                });

                text_tags = (TextView) dialogView.findViewById(R.id.text_tags);
                Log.d(TAG,MainActivity.tags.get(0).toString());
                text_tags.setText(MainActivity.tags.get(0).toString().replace("[","").replace("]",""));

                AlertDialog alertDialog = builder.create();
                alertDialog.show();

                //saveQuestion(view,getActivity().getApplicationContext());
                return true;
            }
        });
        TextView text_question2 = (TextView) view.findViewById(R.id.text_message2);
        text_question2.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                LayoutInflater inflater = getActivity().getLayoutInflater();
                View dialogView = inflater.inflate(R.layout.question_properties_dialog,null);
                AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
                builder.setTitle(R.string.question_properties);
                builder.setView(dialogView);
                builder.setPositiveButton(R.string.save_question, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        Log.d(TAG,"Positive click");
                        Log.d(TAG,"saved");

                        MainActivity.mUser = MainActivity.mUserRef.child(MainActivity.auth.getCurrentUser().getUid());
                        MainActivity.mUser.child("Saved").child(MainActivity.current_question_key.get(1)).setValue(true);

                        Toast.makeText(getActivity().getApplicationContext(), "Question has been saved", Toast.LENGTH_SHORT).show();

                    }
                });

                text_tags = (TextView) dialogView.findViewById(R.id.text_tags);
                Log.d(TAG,MainActivity.tags.get(1).toString());
                text_tags.setText(MainActivity.tags.get(1).toString().replace("[","").replace("]",""));

                AlertDialog alertDialog = builder.create();
                alertDialog.show();

                //saveQuestion(view,getActivity().getApplicationContext());
                return true;
            }
        });
        TextView text_question3 = (TextView) view.findViewById(R.id.text_message3);
        text_question3.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                LayoutInflater inflater = getActivity().getLayoutInflater();
                View dialogView = inflater.inflate(R.layout.question_properties_dialog,null);
                AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
                builder.setTitle(R.string.question_properties);
                builder.setView(dialogView);
                builder.setPositiveButton(R.string.save_question, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        Log.d(TAG,"Positive click");
                        Log.d(TAG,"saved");

                        MainActivity.mUser = MainActivity.mUserRef.child(MainActivity.auth.getCurrentUser().getUid());
                        MainActivity.mUser.child("Saved").child(MainActivity.current_question_key.get(2)).setValue(true);

                        Toast.makeText(getActivity().getApplicationContext(), "Question has been saved", Toast.LENGTH_SHORT).show();

                    }
                });

                text_tags = (TextView) dialogView.findViewById(R.id.text_tags);
                Log.d(TAG,MainActivity.tags.get(2).toString());
                text_tags.setText(MainActivity.tags.get(2).toString().replace("[","").replace("]",""));

                AlertDialog alertDialog = builder.create();
                alertDialog.show();

                //saveQuestion(view,getActivity().getApplicationContext());
                return true;
            }
        });

        return view;

    }

    public void setQuestion1(String text){
        if(getView()!=null) {
            TextView question = (TextView) getView().findViewById(R.id.text_message1);
            question.setText(text);
        } else{
            try {
                TimeUnit.MILLISECONDS.sleep(100);
            } catch(InterruptedException e){
                e.printStackTrace();
            }
        }
    }
    public void setQuestion2(String text){
        if(getView()!=null) {
            TextView question = (TextView) getView().findViewById(R.id.text_message2);
            question.setText(text);
        } else{
            try {
                TimeUnit.MILLISECONDS.sleep(100);
            } catch(InterruptedException e){
                e.printStackTrace();
            }
        }
    }
    public void setQuestion3(String text){
        if(getView()!=null) {
            TextView question = (TextView) getView().findViewById(R.id.text_message3);
            question.setText(text);
        } else{
            try {
                TimeUnit.MILLISECONDS.sleep(100);
            } catch(InterruptedException e){
                e.printStackTrace();
            }
        }
    }

    /**
     * This interface must be implemented by activities that contain this
     * fragment to allow an interaction in this fragment to be communicated
     * to the activity and potentially other fragments contained in that
     * activity.
     * <p>
     * See the Android Training lesson <a href=
     * "http://developer.android.com/training/basics/fragments/communicating.html"
     * >Communicating with Other Fragments</a> for more information.
     */

    /*public interface OnFragmentInteractionListener {
        // TODO: Update argument type and name
        void onFragmentInteraction(Uri uri);
    }*/
}
