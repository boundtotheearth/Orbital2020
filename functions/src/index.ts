import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

export const assignTask = functions.https
    .onCall(async (data, context) => {

        const studentId = data.studentId;
        const createdByName = data.task.createdByName;
        const taskName = data.task.name
        
        
        const device_token = await db.collection("accountTypes")
            .doc(studentId)
            .get()
            .then((doc) => doc.data()?.token);
        
        console.log(device_token);

        
        const payload: admin.messaging.MessagingPayload = {
            notification: {
                title: "You have a new task!",
                body: `${createdByName} has assigned you a new task: ${taskName}`,
                sound: "default"
            },
            data: {
                title: "You have a new task!",
                body: `${createdByName} has assigned you a new task: ${taskName}`,
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
                title: "You have a task update!",
                body: `${task.createdByName} has updated your task: ${task.name}`,
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


export const unassignTask = functions.https.onCall(async (data, context) => {
    const taskName = data.task.name;
    const taskCreatedByName = data.task.createdByName;
    const studentId = data.studentId;

    const device_token = await db.collection("accountTypes")
            .doc(studentId)
            .get()
            .then(doc => doc.data()?.token);
    
    const payload: admin.messaging.MessagingPayload = {
        notification: {
            title: "Task removed",
            body: `${taskCreatedByName} has unassigned you the task: ${taskName}`,
            sound: "default"
        },
        data: {
            title: "Task removed",
            body: `${taskCreatedByName} has unassigned you the task: ${taskName}`,
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


export const updatedCompletionStatus = functions.https
    .onCall(async (data, context) => {
        const taskId = data.taskId;
        const completed = data.status;
        const studentId = data.studentId;
        const byTeacher = data.byTeacher;
        
        const task = await db.collection("tasks")
            .doc(taskId)
            .get()
            .then(doc => doc.data());
        
        if (task?.createdById === studentId) {
            console.log("Self created task. No notifications");
            return ;
        }

        let title = "";
        let body = "";
        let notifToTeacher = true;
        let device_token = "";
        
        if (completed) {
            console.log("Student complete task.");
            title = "Task completed!"
            const studentName = await db.collection("students")
                .doc(studentId)
                .get()
                .then(doc => doc.data()?.name);
            body = `${studentName} has completed your task: ${task?.name}`

        } else if (!completed && byTeacher) {
            console.log("Teacher ask for redo");
            notifToTeacher = false;
            title = "Task needs to be redone!"
            body = `${task?.createdByName} wants you to redo your task: ${task?.name}`

        } else {
            console.log("Student undoes completion");
            title = "Task uncompleted!"
            const studentName = await db.collection("students")
                .doc(studentId)
                .get()
                .then(doc => doc.data()?.name);
            body = `${studentName} has undoed completion of your task: ${task?.name}`
        }

        const payload: admin.messaging.MessagingPayload = {
            notification: {
                title: title,
                body: body,
                sound: "default"
            },
            data: {
                title: title,
                body: body,
                click_action: "FLUTTER_NOTIFICATION_CLICK"
            }
        }

        if (notifToTeacher) {
            device_token = await db.collection("accountTypes")
                .doc(task?.createdById)
                .get()
                .then(doc => doc.data()?.token)
        } else {
            device_token = await db.collection("accountTypes")
                .doc(studentId)
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

    export const updatedVerificationStatus = functions.https
        .onCall(async (data, context) => {
            const taskId = data.taskId;
            const verified = data.status;
            const studentId = data.studentId

        const task = await db.collection("tasks")
        .doc(taskId)
        .get()
        .then(doc => doc.data());
        
        let title = "";
        let body = "";

        if (verified) {
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
                itle: title,
                body: body,
                sound: "default"
            },
            data: {
                title: title,
                body: body,
                click_action: "FLUTTER_NOTIFICATION_CLICK"
            }
        }

        const device_token = await db.collection("accountTypes")
                .doc(studentId)
                .get()
                .then(doc => doc.data()?.token)
        
        try {
            await fcm.sendToDevice(device_token, payload);
            console.log("Notification sent successfully!");
        } catch (err) {
            console.log("Error sending Notification: " + err);
        }
        
    })

    



