package btao.com.quintessencelearning;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import java.util.ArrayList;

/**
 * Created by Brian on 8/6/2017.
 */

public class QuestionsAdapter extends ArrayAdapter<Question> {
    public QuestionsAdapter(Context context, ArrayList<Question> users) {
        super(context, 0, users);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        // Get the data item for this position
        Question question = getItem(position);
        // Check if an existing view is being reused, otherwise inflate the view
        if (convertView == null) {
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.list_row_layout, parent, false);
        }
        // Lookup view for data population
        TextView question_text = (TextView) convertView.findViewById(R.id.question_text);
        TextView question_tags = (TextView) convertView.findViewById(R.id.question_tags);
        // Populate the data into the template view using the data object
        question_text.setText(question.getText());
        question_tags.setText(question.getTags().toString());
        // Return the completed view to render on screen
        return convertView;
    }
}
