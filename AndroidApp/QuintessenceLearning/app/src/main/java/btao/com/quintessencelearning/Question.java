package btao.com.quintessencelearning;

import com.google.firebase.database.Exclude;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Brian on 7/28/2017.
 */

public class Question{
    public String created_by;
    public String key;
    public String text;
    public Long ctime;
    public Long count;
    public List<String> tags;

    public Question() {
    }

    public Question(String created_by, String key, String text, Long ctime,Long count, List<String> tags) {
        this.created_by = created_by;
        this.key = key;
        this.text = text;
        this.ctime = ctime;
        this.count = count;
        this.tags = tags;
    }
    public String getCreatedBy(){
        return created_by;
    }

    public String getKey(){
        return key;
    }
    public String getText(){
        return text;
    }
    public Long getCtime(){
        return ctime;
    }
    public Long getCount(){
        return count;
    }
    public List<String> getTags(){
        return tags;
    }
}