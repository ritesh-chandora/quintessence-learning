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
    public Integer ctime;
    public Integer count;
    public List<String> tags;

    public Question() {
    }

    public Question(String created_by, String key, String text, Integer ctime,Integer count, List<String> tags) {
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
    public Integer getCtime(){
        return ctime;
    }
    public Integer getCount(){
        return count;
    }
    public List<String> getTags(){
        return tags;
    }
}