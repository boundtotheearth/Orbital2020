import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

// export const test = functions.firestore
//     .document("students/{studentId}")
//     .onCreate(async (snapshot, context) => {

//         const payload: admin.messaging.MessagingPayload = {
//             notification: {
//                 title: "Test",
//                 body: "testing",
//                 sound: "default"
//             },
//             data: {
//                 click_action: "FLUTTER_NOTIFICATION_CLICK"
//             }
//         }

//         try {
//             await fcm.sendToDevice("eH-6o4iJf98:APA91bFppzCSuhvKGdLNipbetwq12Ij6UK3soZa-ID78cSXUhLmxcE4ZkEo7kNpRO-90eXD1SGSvFROc3lzfeTYSIayO4n_h_gc0M4upIWaPc7TsOV1aC8H-Prg1APiZ41RZr3gY-Jja", payload);
//             console.log("Notification sent successfully!");
//         } catch (err) {
//             console.log("Error sending Notification: " + err);
//         }
//     })

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

export const updatedTask = functions.firestore
    .document("tasks/{taskId}")
    .onUpdate(async (change, context) => {
        const task = change.before.data();

        const device_tokens: string[] = [];

        const querySnapshots = await change.after.ref
            .collection("students")
            .get();

        for (const studentDoc of querySnapshots.docs) {
            if (studentDoc.id !== task.createdById) {
                console.log(studentDoc.id);
                const token = await db.collection("accountTypes")
                    .doc(studentDoc.id)
                    .get()
                    .then(accountDoc => accountDoc.data()?.token)
                if (token !== undefined) {
                    device_tokens.push(token);
                } else {
                    console.log(`No token for ${studentDoc.id}`);
                }                   
            }
        }

        if (device_tokens.length === 0) {
            console.log("self-created task");
            return ;
        } else {
            device_tokens.forEach(value => console.log(value));
        }


        const payload: admin.messaging.MessagingPayload = {
            notification: {
                title: "You have a task update!",
                body: `${task.createdByName} has updated your task: ${task.name}`,
                sound: "default"
            },
            data: {
                click_action: "FLUTTER_NOTIFICATION_CLICK"
            }
        }

        try {
            await fcm.sendToDevice(device_tokens, payload);
            console.log("Notification sent successfully!");
        } catch (err) {
            console.log("Error sending Notification: " + err);
        }
    })

export const unassignedTask = functions.firestore
    .document("students/{studentId}/tasks/{taskId}")
    .onDelete(async (snapshot, context) => {
        const taskId = context.params.taskId;
        const task = await db.collection("tasks")
            .doc(taskId)
            .get();
        let body = "";
        if (!task.exists) {
            console.log("Task has been deleted")
            body = "A task has been unassigned from you"

        } else if (task.data()?.createdById === context.params.studentId) {
            console.log("Self created task");
            return ;
        } else {
            body = `${task.data()?.createdByName} has unassigned you the task: ${task.data()?.name}`
        }

        const payload: admin.messaging.MessagingPayload = {
            notification: {
                title: "Task removed",
                body: body,
                sound: "default"
            },
            data: {
                click_action: "FLUTTER_NOTIFICATION_CLICK"
            }
        }

        const device_token = await db.collection("accountTypes")
            .doc(context.params.studentId)
            .get()
            .then(doc => doc.data()?.token);
        
        try {
            await fcm.sendToDevice(device_token, payload);
            console.log("Notification sent successfully!");
        } catch (err) {
            console.log("Error sending Notification: " + err);
        }
    })

// export const deleteTask = functions.firestore
//     .document("tasks/{taskId}")
//     .onDelete(async (snapshot, context) => {
//         const task = snapshot.data();
//         const querySnapshots = await db.collection("tasks")
//             .doc(context.params.taskId)
//             .collection("students")
//             .get()
        
//         const device_tokens: string[] = [];
        
//         for (const doc of querySnapshots.docs) {
//             if (doc.id !== task.createdById) {
//                 console.log(doc.id);
//                 const token = await db.collection("accountTypes")
//                     .doc(doc.id)
//                     .get()
//                     .then(accountDoc => accountDoc.data()?.token)
//                 if (token !== undefined) {
//                     device_tokens.push(token);
//                 } else {
//                     console.log(`No token for ${doc.id}`);
//                 }                   
//             }
//         }

//         if (device_tokens.length === 0) {
//             console.log("self-created task");
//             return ;
//         } else {
//             device_tokens.forEach(value => console.log(value));
//         }


//         const payload: admin.messaging.MessagingPayload = {
//             notification: {
//                 title: "Task removed",
//                 body: `${task.data()?.createdByName} has unassigned you the task: ${task.data()?.name}`,
//                 sound: "default"
//             },
//             data: {
//                 click_action: "FLUTTER_NOTIFICATION_CLICK"
//             }
//         }

//         try {
//             await fcm.sendToDevice(device_tokens, payload);
//             console.log("Notification sent successfully!");
//         } catch (err) {
//             console.log("Error sending Notification: " + err);
//         }
//     })

export const updateTaskStatus = functions.firestore
    .document("students/{studentId}/tasks/{taskId}")
    .onUpdate(async (change, context) => {
        const prevState = change.before.data()
        const afterState = change.after.data()
        let title = "";
        let body = "";
        let notifToStudent = true;
        let device_token = "";
        

        const task = await db.collection("tasks")
            .doc(context.params.taskId)
            .get()
            .then(doc => doc.data());
        
        if (task?.createdById === context.params.studentId) {
            console.log("Self created task. No notifications");
            return ;
        }

        if (!prevState.completed && afterState.completed) {
            console.log("Student complete task.");
            notifToStudent = false;
            title = "Task completed!"
            const studentName = await db.collection("students")
                .doc(context.params.studentId)
                .get()
                .then(doc => doc.data()?.name);
            body = `${studentName} has completed your task: ${task?.name}`

        } else if (prevState.completed && !afterState.completed) {
            console.log("No implementation yet.")
            return ;

        } else if (!prevState.verified && afterState.verified) {
            console.log("Teacher verified task.");
            title = "Task verified!"
            body = `${task?.createdByName} has verfied your task: ${task?.name}`

        } else {
            console.log("Teacher unverified task.");
            title = "Task unverified!"
            body = `${task?.createdByName} has unverfied your task: ${task?.name}`
        }

        const payload: admin.messaging.MessagingPayload = {
            notification: {
                title: title,
                body: body,
                sound: "default"
            },
            data: {
                click_action: "FLUTTER_NOTIFICATION_CLICK"
            }
        }

        if (notifToStudent) {
            device_token = await db.collection("accountTypes")
                .doc(context.params.studentId)
                .get()
                .then(doc => doc.data()?.token)
        } else {
            device_token = await db.collection("accountTypes")
                .doc(task?.createdById)
                .get()
                .then(doc => doc.data()?.token)
        }

        try {
            await fcm.sendToDevice(device_token, payload);
            console.log("Notification sent successfully!");
        } catch (err) {
            console.log("Error sending Notification: " + err);
        }
    })



