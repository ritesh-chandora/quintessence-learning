package btao.com.quintessencelearning;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ExpandableListAdapter;
import android.widget.ExpandableListView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class view_by_tag extends AppCompatActivity {
    public static String TAG = "view_by_tag";
    ExpandableListView expandableListView;
    ExpandableListAdapter expandableListAdapter;
    List<String> expandableListTitle;
    HashMap<String, ArrayList<Question>> expandableListDetail;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Intent intent = getIntent();
        expandableListDetail=(HashMap<String, ArrayList<Question>>)intent.getSerializableExtra("tags");

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_view_by_tag);

        expandableListView = (ExpandableListView) findViewById(R.id.tag_expand_view);
        expandableListTitle = new ArrayList<String>(expandableListDetail.keySet());
        expandableListAdapter = new QuestionsExpandAdapter(this, expandableListTitle, expandableListDetail);
        expandableListView.setAdapter(expandableListAdapter);
        expandableListView.setOnGroupExpandListener(new ExpandableListView.OnGroupExpandListener() {

            @Override
            public void onGroupExpand(int groupPosition) {
                Log.d(TAG, expandableListTitle.get(groupPosition) + " List Expanded.");
            }
        });

        expandableListView.setOnGroupCollapseListener(new ExpandableListView.OnGroupCollapseListener() {

            @Override
            public void onGroupCollapse(int groupPosition) {
                Log.d(TAG,expandableListTitle.get(groupPosition) + " List Collapsed.");

            }
        });

        expandableListView.setOnChildClickListener(new ExpandableListView.OnChildClickListener() {
            @Override
            public boolean onChildClick(ExpandableListView parent, View v,
                                        int groupPosition, int childPosition, long id) {
                Log.d(TAG, expandableListTitle.get(groupPosition) + " -> "+ expandableListDetail.get(expandableListTitle.get(groupPosition)).get(childPosition));
                return false;
            }
        });


    }
}
