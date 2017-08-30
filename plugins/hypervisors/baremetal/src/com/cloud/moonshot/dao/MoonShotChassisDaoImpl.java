// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//
// Automatically generated by addcopyright.py at 01/29/2013
// Apache License, Version 2.0 (the "License"); you may not use this
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//
// Automatically generated by addcopyright.py at 04/03/2012
package com.cloud.moonshot.dao;

import com.cloud.moonshot.model.MoonShotChassisVO;
import com.cloud.utils.Pair;
import com.cloud.utils.crypt.DBEncryptionUtil;
import com.cloud.utils.db.DB;
import com.cloud.utils.db.Filter;
import com.cloud.utils.db.GenericDaoBase;
import com.cloud.utils.db.SearchBuilder;
import com.cloud.utils.db.SearchCriteria;

import javax.ejb.Local;
import java.util.List;

/**
 * Created by Raghav on 8/13/2015.
 */
@Local(value = {MoonShotChassisDao.class})
@DB()
public class MoonShotChassisDaoImpl extends GenericDaoBase<MoonShotChassisVO, Long> implements MoonShotChassisDao {

    protected final SearchBuilder<MoonShotChassisVO> listAllSearch;

    public MoonShotChassisDaoImpl() {
        listAllSearch = createSearchBuilder();
        listAllSearch.and("url", listAllSearch.entity().getUrl(), SearchCriteria.Op.EQ);
        listAllSearch.and("zoneId", listAllSearch.entity().getZoneId(), SearchCriteria.Op.EQ);
        listAllSearch.done();
    }

    @Override
    public MoonShotChassisVO findByUuid(String uuid) {
        MoonShotChassisVO moonShotChassisVO = super.findByUuid(uuid);
        decryptPassword(moonShotChassisVO);
        return moonShotChassisVO;
    }

    @Override
    public MoonShotChassisVO persist(MoonShotChassisVO entity) {
        entity.setPassword(DBEncryptionUtil.encrypt(entity.getPassword()));
        MoonShotChassisVO moonShotChassisVO = super.persist(entity);
        decryptPassword(moonShotChassisVO);
        return moonShotChassisVO;
    }

    @Override
    public boolean update(Long aLong, MoonShotChassisVO entity) {
        entity.setPassword(DBEncryptionUtil.encrypt(entity.getPassword()));
        return super.update(aLong, entity);
    }

    @Override
    public List<MoonShotChassisVO> listAll() {
        List<MoonShotChassisVO> moonShotChassisVOs = super.listAll();
        decryptPassword(moonShotChassisVOs);
        return moonShotChassisVOs;
    }

    @Override
    public List<MoonShotChassisVO> listAll(Filter filter) {
        List<MoonShotChassisVO> moonShotChassisVOs = super.listAll(filter);
        decryptPassword(moonShotChassisVOs);
        return moonShotChassisVOs;
    }

    @Override
    public MoonShotChassisVO findByUrl(String url) {
        SearchCriteria<MoonShotChassisVO> sc = listAllSearch.create();
        sc.setParameters("url", url);

        MoonShotChassisVO moonShotChassisVO = findOneBy(sc);
        decryptPassword(moonShotChassisVO);
        return moonShotChassisVO;
    }

    @Override
    public Pair<List<MoonShotChassisVO>, Integer> listWithCount(Long zoneId, Filter filter) {
        SearchCriteria<MoonShotChassisVO> criteria = listAllSearch.create();
        criteria.setParameters("zoneId", zoneId);
        Pair<List<MoonShotChassisVO>, Integer> result = super.searchAndCount(criteria, filter);
        decryptPassword(result.first());
        return result;
    }

    private void decryptPassword(List<MoonShotChassisVO> moonShotChassisVOs) {
        if(moonShotChassisVOs != null && !moonShotChassisVOs.isEmpty()) {
            for (MoonShotChassisVO moonShotChassisVO : moonShotChassisVOs) {
                decryptPassword(moonShotChassisVO);
            }
        }
    }

    private void decryptPassword(MoonShotChassisVO moonShotChassisVO) {
        if(moonShotChassisVO != null) {
            moonShotChassisVO.setPassword(DBEncryptionUtil.decrypt(moonShotChassisVO.getPassword()));
        }
    }
}