package com.cloud.agent.api.storage;

import com.cloud.agent.api.Command;
import com.cloud.agent.api.to.StorageFilerTO;
import com.cloud.storage.StoragePool;
import com.cloud.storage.Volume;
import com.cloud.storage.Volume.Type;

public class ColdMigrateVolumeCommand extends Command {

    long volumeId;
    String volumePath;
    StorageFilerTO srcPool;
    StorageFilerTO destPool;
    String vmInternalName;
    Volume.Type volumeType;
    String destHost;

    public ColdMigrateVolumeCommand(long volumeId, String volumePath, StoragePool srcPool, StoragePool destPool, String vmInternalName,
            String host, Type volumeType, int waitIntervalSeconds) {
        this.volumeId = volumeId;
        this.volumePath = volumePath;
        this.srcPool = new StorageFilerTO(srcPool);
        this.destPool = new StorageFilerTO(destPool);
        this.vmInternalName = vmInternalName;
        this.volumeType = volumeType;
        destHost = host;
        setWait(waitIntervalSeconds);
    }

    @Override
    public boolean executeInSequence() {
        return true;
    }

    public long getVolumeId() {
        return volumeId;
    }

    public void setVolumeId(long volumeId) {
        this.volumeId = volumeId;
    }

    public String getVolumePath() {
        return volumePath;
    }

    public void setVolumePath(String volumePath) {
        this.volumePath = volumePath;
    }

    public StorageFilerTO getSrcPool() {
        return srcPool;
    }

    public void setSrcPool(StorageFilerTO srcPool) {
        this.srcPool = srcPool;
    }

    public StorageFilerTO getDestPool() {
        return destPool;
    }

    public void setDestPool(StorageFilerTO destPool) {
        this.destPool = destPool;
    }

    public Volume.Type getVolumeType() {
        return volumeType;
    }

    public void setVolumeType(Volume.Type volumeType) {
        this.volumeType = volumeType;
    }

    public String getVmInternalName() {
        return vmInternalName;
    }

    public String getDestHost() {
        return destHost;
    }

}
