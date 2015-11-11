global class DeletePreviousInteractionsScheduler implements Schedulable
{
    global void execute(SchedulableContext sc) 
    {
        Id batchProcessId = database.executeBatch(new DeletePreviousInteractions(),200);
    }
}