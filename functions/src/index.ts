import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

export const assignedTask = functions.firestore
    .document("students/{studentId}/tasks/{taskId}")
    .onCreate(async (snapshot, context) => {

        const studentId = context.params.studentId;
        console.log(studentId);
        const task = await db.collection("tasks")
            .doc(context.params.taskId)
            .get();
        if (task.data()?.createdById === studentId) {
            console.log("self created task");
            return ;
        }
        console.log(task.data()?.createdByName);
        console.log(task.data()?.name);
        
        const device_token = await db.collection("accountTypes")
            .doc(studentId)
            .get()
            .then((doc) => doc.data()?.token);
        
        console.log(device_token);

        
        const payload: admin.messaging.MessagingPayload = {
            notification: {
                title: "You have a new task!",
                body: `${task.data()?.createdByName} has assigned you a new task: ${task.data()?.name}`,
                sound: "default"
            },
            data: {
                click_action: "FLUTTER_NOTIFICATION_CLICK"
            }
        }

        try {
            await fcm.sendToDevice(device_token, payload);
            console.log("Notification sent successfully!");
        } catch (err) {
            console.log("Error sending Notification: " + err);
        }
    })


