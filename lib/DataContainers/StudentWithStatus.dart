import 'package:orbital2020/DataContainers/Student.dart';

class StudentWithStatus extends Student {
    bool completed;
    bool verified;

    StudentWithStatus({
        String id,
        String name,
        bool completed,
        bool verified
     }) :
    this.completed = completed ?? false,
    this.verified = verified ?? false,
    super(id: id, name: name);

    Map<String, dynamic> toKeyValuePair() {
        Map<String, dynamic> map = super.toKeyValuePair();
        if(completed != null) map['completed'] = completed;
        if(verified != null) map['verified'] = verified;
        return map;
    }

    int getStatus() {
        if (!completed) {
            return 0;
        } else if (!verified) {
            return 1;
        } else {
            return 2;
        }
    }
}